from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from core.views import ProjectViewSet

# Create a router and register our viewset with it
router = DefaultRouter()
router.register(r'projects', ProjectViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    # Wire up our API using automatic URL routing
    path('api/', include(router.urls)),
]