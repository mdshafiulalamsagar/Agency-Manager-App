from rest_framework import viewsets
from .models import Project
from .serializers import ProjectSerializer

class ProjectViewSet(viewsets.ModelViewSet):
    # This view handles GET, POST, PUT, DELETE automatically
    queryset = Project.objects.all()
    serializer_class = ProjectSerializer