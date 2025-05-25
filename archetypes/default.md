---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
hero: /images/posts/{{ .File.Dir | urlize }}/hero.svg
description: "A brief description of the post content."
theme: Toha
author:
  name: Adam Brown
  image: /images/author/adam.png
image_alt: "Description of the hero image for accessibility"
tags: ["tag1", "tag2"]
categories: ["Category1", "Category2"]
summary: "A short summary of the post for listings and SEO."
---