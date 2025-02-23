from datetime import timedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
import requests
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from .models import OTP, CustomUser
from django.contrib.auth import authenticate
from .serializers import RegisterSerializer
from django.core.mail import send_mail
from django.utils.timezone import now
import random


def send_otp(key, otp_type='phone'):
    """
    Generate and store OTP in the database.
    
    For otp_type 'phone', the function calls Chinguisoft to retrieve an OTP code
    and uses the provided phone number as the key.
    
    For otp_type 'email', it generates a random OTP code and stores it using the email as the key.
    
    Args:
        key (str): The identifier to use for the OTP (phone number for 'phone' OTP or email for 'email' OTP).
        otp_type (str): The type of OTP to generate, either 'phone' or 'email'.
    
    Returns:
        str or None: The OTP code generated or retrieved, or None if an error occurred.
    """
    import random
    from django.utils.timezone import now, timedelta

    # Generate a random OTP code by default
    otp_code = str(random.randint(100000, 999999))

    if otp_type == 'phone':
        # Request OTP from Chinguisoft for phone verification
        url = f"https://chinguisoft.com/api/sms/validation/{settings.CHINGUISOFT_VALIDATION_KEY}"
        headers = {
            'Validation-token': settings.CHINGUISOFT_TOKEN,
            'Content-Type': 'application/json',
        }
        data = {'phone': key, 'lang': 'ar'}
        try:
            response = requests.post(url, headers=headers, json=data)
            response_data = response.json()
            if response.status_code == 200 and "code" in response_data:
                otp_code = response_data["code"]
        except requests.exceptions.RequestException as e:
            print(f"❌ Chinguisoft OTP request failed: {str(e)}")
            return None  # If Chinguisoft fails, do not store an OTP

    # Store OTP in the database.
    # The 'key' is used as the identifier, whether it's a phone number or an email.
    OTP.objects.update_or_create(
        phone_number=key,  # 'phone_number' field holds the key (phone or email) based on otp_type.
        otp_type=otp_type,
        defaults={
            "code": otp_code,
            "created_at": now(),
            "expiry_time": now() + timedelta(minutes=10)
        }
    )

    return otp_code




# Login View
class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")

        if not username or not password:
            return Response({"error": "Username and password are required"}, status=400)

        # Authenticate user
        user = authenticate(request, username=username, password=password)
        if user is None:
            return Response({"error": "Invalid credentials"}, status=401)

        # Check if phone is verified
        if not user.is_phone_verified:
            send_otp(user.phone_number)
            return Response({"message": "Phone not verified. OTP sent for verification."})

        # Issue JWT tokens if verified
        refresh = RefreshToken.for_user(user)
        return Response({
            "message": "Login successful",
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        })


# Register User & Send OTP
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            send_otp(user.phone_number)
            return Response({"message": "OTP sent for verification."}, status=201)
        return Response(serializer.errors, status=400)


# Verify OTP for Registration/Login
class VerifyOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        otp_code = request.data.get("otp")
        is_password_reset = request.data.get("is_password_reset", False)

        if not otp_code:
            return Response({"error": "OTP is required"}, status=400)

        # ✅ Check OTP type
        otp_type = "email" if is_password_reset else "phone"
        otp_entry = OTP.objects.filter(code=otp_code, otp_type=otp_type).first()

        if not otp_entry or not otp_entry.is_valid():
            return Response({"error": "Invalid or expired OTP"}, status=400)

        if is_password_reset:
            return Response({"message": "OTP verified for password reset."})  # ✅ Redirect to Password Reset
        else:
            user = CustomUser.objects.get(phone_number=otp_entry.phone_number)
            user.is_phone_verified = True
            user.save()

            refresh = RefreshToken.for_user(user)
            return Response({
                "message": "Phone number verified successfully",
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            })



# Password Reset Request (Email OTP)
class PasswordResetView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get("email")
        if not email:
            return Response({"error": "Email is required"}, status=400)

        try:
            user = CustomUser.objects.get(email=email)
        except CustomUser.DoesNotExist:
            return Response({"error": "No user with this email found"}, status=404)

        # Generate OTP and store it using the email as the key
        otp_code = send_otp(user.email, otp_type='email')

        # Send the OTP via email
        send_mail(
            "Password Reset OTP",
            f"Your OTP is: {otp_code}",
            "noreply@jedweli.com",
            [email],
            html_message=f"""
                <div style="background: #f0f8ff; padding: 20px; border-radius: 5px;">
                    <h1 style="color: #007bff;">Password Reset Request</h1>
                    <p>Use the OTP below to reset your password:</p>
                    <h3 style="color: #007bff;">{otp_code}</h3>
                    <p>If you didn’t request this, please ignore it.</p>
                </div>
            """,
        )

        return Response({"message": "OTP sent to email."})


# Password Reset Confirmation
class PasswordResetConfirmView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        otp_code = request.data.get("otp")
        new_password = request.data.get("password")
        confirm_password = request.data.get("confirm_password")

        if not otp_code or not new_password or not confirm_password:
            return Response({"error": "All fields are required"}, status=400)

        if new_password != confirm_password:
            return Response({"error": "Passwords do not match"}, status=400)

        # Find the OTP entry for email type
        otp_entry = OTP.objects.filter(code=otp_code, otp_type="email").first()

        if not otp_entry or not otp_entry.is_valid():
            return Response({"error": "Invalid or expired OTP"}, status=400)

        try:
            # Retrieve user using the email stored in otp_entry.phone_number
            user = CustomUser.objects.get(email=otp_entry.phone_number)
        except CustomUser.DoesNotExist:
            return Response({"error": "User not found"}, status=400)

        # Reset password
        user.set_password(new_password)
        user.save()

        # Delete OTP after successful reset
        otp_entry.delete()

        return Response({"message": "Password reset successful. You can now log in."})

