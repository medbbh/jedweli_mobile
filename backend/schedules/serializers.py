from rest_framework import serializers
from .models import Schedule, Class, Favorite

class ClassSerializer(serializers.ModelSerializer):
    start_time = serializers.TimeField(format="%H:%M", input_formats=["%H:%M"])
    end_time = serializers.TimeField(format="%H:%M", input_formats=["%H:%M"])
    
    class Meta:
        model = Class
        fields = '__all__'

class ScheduleSerializer(serializers.ModelSerializer):
    classes = ClassSerializer(many=True, read_only=True)

    class Meta:
        model = Schedule
        fields = "__all__"
        extra_kwargs = {
            "owner": {"read_only": True},
        }


class FavoriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Favorite
        fields = ['id', 'schedule', 'added_at']  # No 'user' field to avoid errors
        read_only_fields = ['id', 'added_at']  # Prevent manual input

    def create(self, validated_data):
        return Favorite.objects.create(user=self.context['request'].user, **validated_data)

