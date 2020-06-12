# Generated by Django 2.2.11 on 2020-06-12 13:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("datamodel", "0002_auto_20200525_1024"),
    ]

    operations = [
        migrations.AddField(
            model_name="contactmoment",
            name="voorkeurstaal",
            field=models.CharField(
                blank=True,
                help_text="Een ISO 639-2/B taalcode waarin de inhoud van het INFORMATIEOBJECT is vastgelegd. Voorbeeld: `nld`. Zie: https://www.iso.org/standard/4767.html",
                max_length=3,
            ),
        ),
    ]