from django.utils import timezone
from rest_framework import viewsets, status, permissions
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db import IntegrityError

from users.models import CustomUser
from .models import Schedule, Class, Favorite, ScheduleAccess, ScheduleFollower
from .serializers import ScheduleSerializer, ClassSerializer, FavoriteSerializer
from rest_framework.decorators import api_view
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q

# -----------------------------
# ✅ Custom Permission for Ownership Enforcement
# -----------------------------
class IsOwnerOrReadOnly(permissions.BasePermission):
    """Custom permission to allow only owners to edit/delete their schedules."""

    def has_object_permission(self, request, view, obj):
        # Read permissions are allowed for everyone (GET, HEAD, OPTIONS)
        if request.method in permissions.SAFE_METHODS:
            return True
        # Write permissions are only allowed for the owner
        return obj.owner == request.user


# -----------------------------
# ✅ Schedules API (CRUD)
# -----------------------------
class ScheduleViewSet(viewsets.ModelViewSet):
    """Viewset for managing schedules (Only owners can update/delete)."""
    
    serializer_class = ScheduleSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerOrReadOnly]

    def get_queryset(self):
        """Return only schedules that belong to the authenticated user."""
        return Schedule.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        """Set the owner of the schedule before saving."""
        serializer.save(owner=self.request.user)

    def destroy(self, request, *args, **kwargs):
        """Allow only the schedule owner to delete the schedule."""
        schedule = self.get_object()
        if schedule.owner != request.user:
            return Response({'error': 'You can only delete your own schedules.'}, status=status.HTTP_403_FORBIDDEN)
        
        # Delete the schedule and its related classes
        schedule.delete()
        return Response({'message': 'Schedule deleted successfully'}, status=status.HTTP_204_NO_CONTENT)


# -----------------------------
# ✅ Classes API (CRUD)
# -----------------------------
class ClassViewSet(viewsets.ModelViewSet):
    """
    Viewset for managing classes.
    Allows updating/deleting a class if the authenticated user is the schedule owner
    or if the user has been granted 'edit' access via ScheduleAccess.
    """
    serializer_class = ClassSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        # Return classes where the schedule owner is the user,
        # or where the user has 'edit' access to the schedule.
        return Class.objects.filter(
            Q(schedule__owner=user) |
            Q(schedule__access_list__user=user, schedule__access_list__permission='edit')
        ).distinct()

    def has_edit_permission(self, class_instance):
        user = self.request.user
        # Check if the user is the owner of the schedule.
        if class_instance.schedule.owner == user:
            return True
        # Otherwise, check if there's a ScheduleAccess record granting 'edit' access.
        return ScheduleAccess.objects.filter(
            schedule=class_instance.schedule,
            user=user,
            permission='edit'
        ).exists()

    def update(self, request, *args, **kwargs):
        class_instance = self.get_object()
        if not self.has_edit_permission(class_instance):
            return Response(
                {"error": "You do not have permission to update classes for this schedule."},
                status=status.HTTP_403_FORBIDDEN
            )
        return super().update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        class_instance = self.get_object()
        if not self.has_edit_permission(class_instance):
            return Response(
                {"error": "You do not have permission to delete classes for this schedule."},
                status=status.HTTP_403_FORBIDDEN
            )
        class_instance.delete()
        return Response({"message": "Class deleted successfully"}, status=status.HTTP_204_NO_CONTENT)


    def destroy(self, request, *args, **kwargs):
        """Ensure only the owner of the schedule can delete a class."""
        class_instance = self.get_object()
        if class_instance.schedule.owner != request.user:
            return Response(
                {"error": "You can only delete classes from your own schedules."},
                status=status.HTTP_403_FORBIDDEN
            )

        class_instance.delete()
        return Response({"message": "Class deleted successfully"}, status=status.HTTP_204_NO_CONTENT)



# -----------------------------
# ✅ Favorites API (Users Can Favorite Only Their Own Schedules)
# -----------------------------
class FavoriteViewSet(viewsets.ModelViewSet):
    """Allow users to favorite schedules (Prevents duplicate favorites)."""

    serializer_class = FavoriteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Return only the current user's favorites."""
        return Favorite.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        """Allow users to favorite schedules, ensuring no duplicates."""
        user = request.user
        schedule_id = request.data.get('schedule')

        if not schedule_id:
            return Response({'error': 'Schedule ID is required.'}, status=status.HTTP_400_BAD_REQUEST)

        # Prevent duplicate favorites
        if Favorite.objects.filter(user=user, schedule_id=schedule_id).exists():
            return Response({'message': 'Schedule is already in favorites.'}, status=status.HTTP_200_OK)

        try:
            return super().create(request, *args, **kwargs)
        except IntegrityError:
            return Response({'error': 'Favorite already exists.'}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_schedule_sharing(request, schedule_id):
    """Allow schedule owners to enable/disable sharing."""
    try:
        schedule = Schedule.objects.get(id=schedule_id, owner=request.user)
        schedule.is_public = not schedule.is_public  # Toggle sharing
        schedule.save()

        return Response(
            {"message": "Sharing updated", "is_public": schedule.is_public, "shareable_id": schedule.shareable_id},
            status=status.HTTP_200_OK
        )

    except Schedule.DoesNotExist:
        return Response({"error": "Schedule not found or you are not the owner"}, status=status.HTTP_403_FORBIDDEN)

@api_view(['GET'])
def get_shared_schedule(request, shareable_id):
    """Fetch a shared schedule by its unique link and track unique viewers."""
    try:
        schedule = Schedule.objects.get(shareable_id=shareable_id, is_public=True)

        # ✅ Identify the user (logged-in user or anonymous)
        user = request.user if request.user.is_authenticated else None
        session_id = request.session.session_key

        if not session_id:
            # Generate a unique session ID if not already present
            request.session.save()
            session_id = request.session.session_key

        # ✅ Check if the user already accessed this schedule
        existing_follower = ScheduleFollower.objects.filter(
            schedule=schedule,
            user=user,
            session_id=session_id
        ).first()

        if existing_follower:
            # Update last access time
            existing_follower.accessed_at = timezone.now()
            existing_follower.save()
        else:
            # Create a new follower entry
            ScheduleFollower.objects.create(schedule=schedule, user=user, session_id=session_id)

        return Response(ScheduleSerializer(schedule).data, status=status.HTTP_200_OK)

    except Schedule.DoesNotExist:
        return Response({'error': 'Schedule not found or sharing is disabled'}, status=status.HTTP_404_NOT_FOUND)
    

@api_view(['GET'])
def get_schedule_followers(request, schedule_id):
    """Allow schedule owners to see unique followers (logged-in users + anonymous)."""
    try:
        schedule = Schedule.objects.get(id=schedule_id, owner=request.user)

        # ✅ Count unique authenticated users
        unique_users_count = schedule.followers.filter(user__isnull=False).values("user").distinct().count()

        # ✅ Count unique anonymous users by session ID
        unique_anonymous_count = schedule.followers.filter(user__isnull=True).values("session_id").distinct().count()

        return Response({
            "schedule_id": schedule_id,
            "unique_users": unique_users_count,
            "unique_anonymous": unique_anonymous_count,
            "total_followers": unique_users_count + unique_anonymous_count
        }, status=status.HTTP_200_OK)

    except Schedule.DoesNotExist:
        return Response({"error": "Schedule not found or you are not the owner"}, status=status.HTTP_403_FORBIDDEN)

    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def grant_schedule_access(request, schedule_id):
    """Allow the schedule owner to grant view/edit access to another user."""
    try:
        schedule = get_object_or_404(Schedule, id=schedule_id, owner=request.user)
        username = request.data.get("username")
        permission_level = request.data.get("permission", "view")  # Default is 'view'

        if not username:
            return Response({"error": "Username is required"}, status=status.HTTP_400_BAD_REQUEST)

        # Ensure the invited user exists
        invited_user = get_object_or_404(CustomUser, username=username)

        # Prevent the owner from granting access to themselves
        if invited_user == schedule.owner:
            return Response({"error": "You are already the owner of this schedule"}, status=status.HTTP_400_BAD_REQUEST)

        # Grant access or update existing permissions
        access, created = ScheduleAccess.objects.update_or_create(
            schedule=schedule,
            user=invited_user,
            defaults={"permission": permission_level}
        )

        return Response(
            {
                "message": f"Access granted to {username} as {permission_level}",
                "permission": permission_level
            },
            status=status.HTTP_200_OK
        )

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def revoke_schedule_access(request, schedule_id, username):
    """Allow the schedule owner to revoke access from a user."""
    try:
        schedule = get_object_or_404(Schedule, id=schedule_id, owner=request.user)
        invited_user = get_object_or_404(CustomUser, username=username)

        # Ensure the user exists in the access list
        access_entry = ScheduleAccess.objects.filter(schedule=schedule, user=invited_user).first()

        if not access_entry:
            return Response({"error": "User does not have access to this schedule"}, status=status.HTTP_400_BAD_REQUEST)

        access_entry.delete()
        return Response({"message": f"Access revoked from {username}"}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_schedule_access(request, schedule_id):
    """Allow the schedule owner to view who has access to their schedule."""
    try:
        schedule = get_object_or_404(Schedule, id=schedule_id, owner=request.user)
        access_list = schedule.access_list.all().values("user__username", "permission")

        return Response({"schedule_id": schedule_id, "access_list": list(access_list)}, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)  

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_shared_with_me_schedules(request):
    """
    Return all schedules that have been shared with the current user via ScheduleAccess.
    """
    try:
        access_entries = ScheduleAccess.objects.filter(user=request.user)
        schedules = [entry.schedule for entry in access_entries]
        serializer = ScheduleSerializer(schedules, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
