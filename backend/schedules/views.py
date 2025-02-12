from rest_framework import viewsets,status, permissions
from .models import Schedule, Class, Favorite
from .serializers import ScheduleSerializer, ClassSerializer, FavoriteSerializer
from rest_framework.response import Response
from django.db import IntegrityError

class ScheduleViewSet(viewsets.ModelViewSet):
    serializer_class = ScheduleSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        """Return schedules that belong to the authenticated user."""
        return Schedule.objects.filter(owner=self.request.user)

    def perform_create(self, serializer):
        if self.request.user.is_anonymous:
            raise Exception("User is not authenticated")
        # Here we force the owner to be the current user.
        serializer.save(owner=self.request.user)


class ClassViewSet(viewsets.ModelViewSet):
    serializer_class = ClassSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Class.objects.filter(schedule__owner=self.request.user)

# class FavoriteViewSet(viewsets.ModelViewSet):
#     serializer_class = FavoriteSerializer
#     permission_classes = [permissions.IsAuthenticated]  # Restrict to logged-in users

#     def get_queryset(self):
#         return Favorite.objects.filter(user=self.request.user)  # Get only current user's favorites

class FavoriteViewSet(viewsets.ModelViewSet):
    serializer_class = FavoriteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Return only the current user's favorites
        return Favorite.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        user = request.user
        schedule_id = request.data.get('schedule')
        
        if not schedule_id:
            return Response({'error': 'Schedule ID is required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Check if the favorite already exists for this user and schedule
        if Favorite.objects.filter(user=user, schedule_id=schedule_id).exists():
            # Optionally, return a success message if the favorite is already set
            return Response({'message': 'Schedule is already in favorites.'}, status=status.HTTP_200_OK)
        
        try:
            # Proceed with creation if it doesn't exist yet
            return super().create(request, *args, **kwargs)
        except IntegrityError:
            # In case of a race condition or unexpected duplicate, catch the error
            return Response({'error': 'Favorite already exists.'}, status=status.HTTP_400_BAD_REQUEST)
