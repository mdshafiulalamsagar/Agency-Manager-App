from django.db import models

class Project(models.Model):
    PRIORITY_CHOICES = [('High', 'High'), ('Medium', 'Medium'), ('Low', 'Low')]
    PHASE_CHOICES = [
        ('Planning', 'Planning'), ('Designing', 'Designing'),
        ('Development', 'Development'), ('Testing', 'Testing'), ('Deployed', 'Deployed')
    ]

    # Basic Info
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    
    # Client Info
    client_name = models.CharField(max_length=100)
    client_email = models.EmailField(blank=True, null=True)
    client_phone = models.CharField(max_length=20, blank=True, null=True)
    
    # Logistics
    assigned_to = models.CharField(max_length=100, default="Unassigned")
    deadline = models.DateField()
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='Medium')
    
    # Financials
    budget = models.DecimalField(max_digits=10, decimal_places=2)
    expense = models.DecimalField(max_digits=10, decimal_places=2, default=0.00) # Total expense sum
    expense_history = models.TextField(blank=True, default="") # Stores detailed expense logs for the invoice
    
    # Status & Extras
    progress = models.IntegerField(default=0)
    phase = models.CharField(max_length=20, choices=PHASE_CHOICES, default='Planning')
    resources = models.TextField(blank=True, null=True)
    rating = models.IntegerField(default=0)

    def __str__(self):
        return self.title