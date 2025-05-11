# hugo-toha.github.io

[![Netlify Status](https://api.netlify.com/api/v1/badges/b1b93b02-f278-440b-ae1b-304e9f4c4ab5/deploy-status)](https://app.netlify.com/sites/toha/deploys) [![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fhugo-toha%2Fhugo-toha.github.io%2Fbadge%3Fref%3Dmain&style=flat)](https://actions-badge.atrox.dev/hugo-toha/hugo-toha.github.io/goto?ref=main) ![Repository Size](https://img.shields.io/github/repo-size/hugo-toha/hugo-toha.github.io) ![Contributor](https://img.shields.io/github/contributors/hugo-toha/hugo-toha.github.io) ![Last Commit](https://img.shields.io/github/last-commit/hugo-toha/hugo-toha.github.io) ![License](https://img.shields.io/github/license/hugo-toha/hugo-toha.github.io) ![Open Issues](https://img.shields.io/github/issues/hugo-toha/hugo-toha.github.io?color=important) ![Open Pull Requests](https://img.shields.io/github/issues-pr/hugo-toha/hugo-toha.github.io?color=yellowgreen) ![Security Headers](https://img.shields.io/security-headers?url=https%3A%2F%2Fhugo-toha.github.io%2F) [![This project is using Percy.io for visual regression testing.](https://percy.io/static/images/percy-badge.svg)](https://percy.io/b7cb60ab/hugo-toha.github.io)

An example hugo static site with Toha theme.

Attributions:
- <a href='https://www.freepik.com/vectors/business'>Business vector created by studiogstock - www.freepik.com</a>

# Adam Brown's Cloud

This is the source code for my personal website, built with Hugo and the Toha theme.

## Overview

This site is built using [Hugo](https://gohugo.io/) and the [Toha theme](https://github.com/hugo-toha/toha). It includes various features such as a blog, portfolio, and notes section, all of which can be configured via the `hugo.yaml` file

## Features

- **Blog**: Share your thoughts and articles.
- **Portfolio**: Showcase your projects and work.
- **Notes**: A section for quick notes and documentation.
- **Comments**: Enable comments on your posts using various services (e.g., Disqus, Giscus).
- **Analytics**: Track your site's performance with Google Analytics or other services.
- **Custom CSS/JS**: Add your own styles and scripts to customize the site.

## Creating New Pages

### Blog Posts

1. Create a new markdown file in the `content/blog` directory.
2. Add the following front matter at the top of the file:

   ```yaml
   ---
   title: "Your Post Title"
   date: 2023-01-01
   draft: false
   ---
   ```

3. Write your content below the front matter.

### Portfolio Projects

1. Create a new markdown file in the `content/portfolio` directory.
2. Add the following front matter:

   ```yaml
   ---
   title: "Your Project Title"
   date: 2023-01-01
   draft: false
   image: /images/portfolio/your-image.jpg
   ---
   ```

3. Write your project description and details below the front matter.

### Notes

1. Create a new markdown file in the `content/notes` directory.
2. Add the following front matter:

   ```yaml
   ---
   title: "Your Note Title"
   date: 2023-01-01
   draft: false
   hero: /images/notes/your-hero-image.jpg
   ---
   ```

3. Write your note content below the front matter.

## Hero Images

- **Blog Posts**: Use the `image` field in the front matter to specify a hero image for your blog post.
- **Portfolio Projects**: Use the `image` field to set a hero image for your project.
- **Notes**: Use the `hero` field to set a hero image for your note.

### Where to Place Hero Images (Workaround)

Due to a theme limitation, hero images must be placed in the `assets` directory (not `static`). For example:

- For a blog post or note at `content/posts/your-post/index.md`, place the hero image at:
  - `assets/images/posts/your-post/hero.svg`

Then, in your front matter, reference the image as:

```yaml
hero: images/posts/your-post/hero.svg
```

This ensures the theme's helper partial can find and process the image correctly.

## Configuration

The site's configuration is managed via the `hugo.yaml` file. Key sections include:

- **Languages**: Configure multiple languages for your site.
- **Params**: Set site-wide parameters, including features, footer, and more.
- **Module**: Manage Hugo modules and theme imports.

## Development

To run the site locally:

1. Install Hugo (extended version recommended).
2. Clone this repository.
3. Run `hugo server -w` in the project directory.
4. Visit `http://localhost:1313` in your browser.

## Deployment

The site is deployed automatically via GitHub Actions. Any changes pushed to the `main` branch will trigger a rebuild and deployment.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
