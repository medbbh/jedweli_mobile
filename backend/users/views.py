from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
import requests
from django.conf import settings
from rest_framework_simplejwt.tokens import RefreshToken
from .models import OTP, CustomUser
from django.contrib.auth import authenticate
from .serializers import RegisterSerializer
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes
from django.core.mail import send_mail
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from django.core.validators import validate_email
from django.utils.timezone import now

# Register a new user
class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User registered successfully"}, status=201)
        return Response(serializer.errors, status=400)

class LoginWithOTPView(APIView):
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

        # Send OTP via Chinguisoft
        url = f"https://chinguisoft.com/api/sms/validation/{settings.CHINGUISOFT_VALIDATION_KEY}"
        headers = {
            'Validation-token': settings.CHINGUISOFT_TOKEN,
            'Content-Type': 'application/json',
        }
        data = {
            'phone': user.phone_number,
            'lang': 'ar',
        }

        try:
            response = requests.post(url, headers=headers, json=data)
            response_data = response.json()

            if response.status_code != 200 or "code" not in response_data:
                return Response({"error": "Failed to send OTP"}, status=400)

            otp_code = str(response_data["code"])  # Extract OTP

            # Store OTP in database for later verification
            OTP.objects.update_or_create(
                phone_number=user.phone_number,
                defaults={"code": otp_code, "created_at": now()}
            )

            # Mask phone number (e.g., "******28")
            masked_phone = f"******{user.phone_number[-2:]}"

            return Response({
                "message": f"OTP has been sent to {masked_phone}. Please verify."
            })

        except requests.exceptions.RequestException as e:
            return Response({"error": f"OTP service unavailable: {str(e)}"}, status=500)

# Verify OTP 
class VerifyLoginOTPView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        username = request.data.get("username")
        otp_code = request.data.get("otp")

        if not username or not otp_code:
            return Response({"error": "Username and OTP are required"}, status=400)

        # Check if the user exists
        try:
            user = CustomUser.objects.get(username=username)
        except CustomUser.DoesNotExist:
            return Response({"error": "Invalid username"}, status=400)

        # Retrieve OTP from database
        otp_entry = OTP.objects.filter(phone_number=user.phone_number, code=otp_code).first()

        if not otp_entry:
            return Response({"error": "Invalid OTP"}, status=400)

        # OTP is valid, issue JWT tokens
        refresh = RefreshToken.for_user(user)

        # Delete OTP after successful verification
        otp_entry.delete()
        user.is_phone_verified = True
        return Response({
            "message": "OTP verification successful",
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        })


# Password reset request
User = get_user_model()

class PasswordResetView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({"error": "Email is required"}, status=400)

        try:
            validate_email(email)
        except ValidationError:
            return Response({"error": "Invalid email format"}, status=400)

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response({"error": "No user with this email found"}, status=404)

        # Generate password reset token and UID
        token = default_token_generator.make_token(user)
        uid = urlsafe_base64_encode(force_bytes(user.pk))

        # Construct password reset URL
        reset_url = f"{request.build_absolute_uri('/')[:-1]}/password-reset-confirm/{uid}/{token}/"

        # Send email
        send_mail(
            subject="Password Reset Request",
            message=f"Click the link to reset your password: {reset_url}",
            from_email="your_email@example.com",
            recipient_list=[email],
        )

        return Response({"message": "Password reset link sent to your email."})


# Password reset confirmation
class PasswordResetConfirmView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, uidb64, token):
        try:
            uid = urlsafe_base64_decode(uidb64).decode()
            user = User.objects.get(pk=uid)
        except (User.DoesNotExist, ValueError, TypeError, OverflowError):
            return Response({"error": "Invalid link"}, status=400)

        if not default_token_generator.check_token(user, token):
            return Response({"error": "Invalid or expired token"}, status=400)

        # Set the new password
        new_password = request.data.get('password')
        if not new_password or len(new_password) < 8:
            return Response({"error": "Password must be at least 8 characters long"}, status=400)

        user.set_password(new_password)
        user.save()

        return Response({"message": "Password reset successful"})