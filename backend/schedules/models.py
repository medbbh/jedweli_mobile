from django.db import models
from users.models import CustomUser


class Schedule(models.Model):
    owner = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="schedules")
    title = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} - {self.owner}"

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

