---
title: "{{ name }}"
---

**{{ servings }} servings | {{ prep_minutes }} prep minutes | {{ cook_minutes }} cook minutes**

{% if url %}**Adapted from [{{ author }}]({{ url }})**{% endif %}

## Ingredients

{% for ingredient in ingredients %}* {% if ingredient.amount %}{{ ingredient.amount }} {% endif %}{% if ingredient.unit %}{{ ingredient.unit }} {% endif %}{{ ingredient.name }}
{% endfor %}

## Method

{% for step in steps %}{{ loop.index }}. {{ step }}
{% endfor %}

