from django.urls import path
from .views import RegisterView, LoginWithOTPView, VerifyLoginOTPView, PasswordResetView, PasswordResetConfirmView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginWithOTPView.as_view(), name='login-with-otp'),
    path('verify-otp/', VerifyLoginOTPView.as_view(), name='verify-otp'),
    path('password-reset/', PasswordResetView.as_view(), name='password-reset'),
    path('password-reset-confirm/<uidb64>/<token>/', PasswordResetConfirmView.as_view(), name='password-reset-confirm'),
]
