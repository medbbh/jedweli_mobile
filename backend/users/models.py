from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.timezone import now, timedelta


class CustomUser(AbstractUser):
    phone_number = models.CharField(max_length=8, unique=True)
    is_phone_verified = models.BooleanField(default=False)

    REQUIRED_FIELDS = ['phone_number', 'email']

class OTP(models.Model):
    OTP_TYPE_CHOICES = [
        ('phone', 'Phone Verification'),
        ('email', 'Password Reset'),
    ]

    phone_number = models.CharField(max_length=8, unique=True)
    code = models.CharField(max_length=6)  
    otp_type = models.CharField(max_length=10, choices=OTP_TYPE_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)
    expiry_time = models.DateTimeField()

    def save(self, *args, **kwargs):
        """Ensure expiry_time is correctly set only on creation"""
        if not self.expiry_time:
            self.expiry_time = now() + timedelta(minutes=10)
        super().save(*args, **kwargs)

    def is_valid(self):
        """Check if the OTP exists and is still valid"""
        return self and now() < self.expiry_time
