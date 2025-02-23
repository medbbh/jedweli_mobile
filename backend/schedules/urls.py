from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    ScheduleViewSet, ClassViewSet, FavoriteViewSet,
    get_shared_schedule, get_shared_with_me_schedules, grant_schedule_access, list_schedule_access, 
    revoke_schedule_access,toggle_schedule_sharing,get_schedule_followers
    )

router = DefaultRouter()
router.register(r'schedules', ScheduleViewSet, basename='schedule')
router.register(r'classes', ClassViewSet, basename='class')
router.register(r'favorites', FavoriteViewSet, basename='favorite')

urlpatterns = [
    path('', include(router.urls)),
    path('shared/<uuid:shareable_id>/', get_shared_schedule, name="shared-schedule"),
    path('schedules/<int:schedule_id>/toggle-sharing/', toggle_schedule_sharing, name="toggle-sharing"),
    path('schedules/<int:schedule_id>/followers/', get_schedule_followers, name="schedule-followers"),

    path('schedules/<int:schedule_id>/access/', grant_schedule_access, name="grant-access"),
    path('schedules/<int:schedule_id>/access/<str:username>/', revoke_schedule_access, name="revoke-access"),
    path('schedules/<int:schedule_id>/access-list/', list_schedule_access, name="list-access"),
    path('shared-with-me/', get_shared_with_me_schedules, name="shared-with-me"),

]
