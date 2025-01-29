from rest_framework import viewsets, permissions
from .models import Schedule, Class, Favorite
from .serializers import ScheduleSerializer, ClassSerializer, FavoriteSerializer

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

class FavoriteViewSet(viewsets.ModelViewSet):
    serializer_class = FavoriteSerializer
    permission_classes = [permissions.IsAuthenticated]  # Restrict to logged-in users

    def get_queryset(self):
        return Favorite.objects.filter(user=self.request.user)  # Get only current user's favorites

