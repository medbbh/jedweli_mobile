from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ScheduleViewSet, ClassViewSet, FavoriteViewSet

router = DefaultRouter()
router.register(r'schedules', ScheduleViewSet, basename='schedule')
router.register(r'classes', ClassViewSet, basename='class')
router.register(r'favorites', FavoriteViewSet, basename='favorite')

urlpatterns = [
    path('', include(router.urls)),
]
