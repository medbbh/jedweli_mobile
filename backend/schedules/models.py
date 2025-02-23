from django.db import models
from users.models import CustomUser
import uuid


# class Schedule(models.Model):
#     owner = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="schedules")
#     title = models.CharField(max_length=255)
#     created_at = models.DateTimeField(auto_now_add=True)
#     updated_at = models.DateTimeField(auto_now=True)

#     def __str__(self):
#         return f"{self.title} - {self.owner}"


class Schedule(models.Model):
    owner = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="schedules")
    title = models.CharField(max_length=255)
    shareable_id = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)  # ✅ Unique link for sharing
    is_public = models.BooleanField(default=False)  # ✅ Control whether the schedule is shareable
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.owner}"


class ScheduleFollower(models.Model):
    """Tracks who accessed the schedule (anonymized for privacy)."""
    schedule = models.ForeignKey(Schedule, on_delete=models.CASCADE, related_name="followers")
    user = models.ForeignKey(CustomUser, null=True, blank=True, on_delete=models.CASCADE)  # Logged-in users
    session_id = models.CharField(max_length=255, null=True, blank=True)  # Anonymous users
    accessed_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Anonymous Follower for {self.schedule.title}"
    
class ScheduleAccess(models.Model):
    """Tracks which users have access to a schedule and their permission level."""
    PERMISSION_CHOICES = [
        ('view', 'View Only'),
        ('edit', 'Edit'),
    ]

    schedule = models.ForeignKey(Schedule, on_delete=models.CASCADE, related_name="access_list")
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="accessible_schedules")
    permission = models.CharField(max_length=10, choices=PERMISSION_CHOICES, default="view")
    granted_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("schedule", "user")  # Prevent duplicate access entries

    def __str__(self):
        return f"{self.user.username} - {self.permission} access to {self.schedule.title}"

class Class(models.Model):
    schedule = models.ForeignKey(Schedule, on_delete=models.CASCADE, related_name="classes")
    name = models.CharField(max_length=255)
    instructor = models.CharField(max_length=255)
    day = models.CharField(max_length=20)
    start_time = models.TimeField()
    end_time = models.TimeField()
    location = models.CharField(max_length=255)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.day}"

class Favorite(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="favorites")
    schedule = models.ForeignKey(Schedule, on_delete=models.CASCADE, related_name="favorited_by")
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'schedule')  # Prevent duplicate favorites

    def __str__(self):
        return f"{self.user.username} -> {self.schedule.title}"

