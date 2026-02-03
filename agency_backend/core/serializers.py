from rest_framework import serializers
from .models import Project

class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        # We are selecting all fields to be converted to JSON
        fields = '__all__'