from django.contrib import admin
from .models import *

# Register your models here.
admin.site.register(Schedule)
admin.site.register(ScheduleFollower)
admin.site.register(Class)
admin.site.register(Favorite)