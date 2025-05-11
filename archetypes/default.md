—
title: “{{ replace .Name “-“ “ “ | title }}”
date: {{ .Date }}
draft: true
tags: [“tag1”, “tag2”]
categories: [“Category1”, “Category2”]
summary: “A short summary of the post for listings and SEO.”
hero: “images/posts/{{ .File.Dir | urlize }}/hero.svg”
—