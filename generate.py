import os
import markdown
from jinja2 import Environment, FileSystemLoader

def load_posts(posts_dir="posts"):
    posts = []
    if not os.path.exists(posts_dir):
        os.makedirs(posts_dir)
    
    for filename in sorted(os.listdir(posts_dir), reverse=True):
        if filename.endswith(".md"):
            filepath = os.path.join(posts_dir, filename)
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
                lines = content.split("\n")
                image_url = lines[0].strip() if lines[0].startswith("http") else ""
                text_content = markdown.markdown("\n".join(lines[1:]) if image_url else content)
                posts.append({
                    "title": filename.replace(".md", ""),
                    "image": image_url,
                    "content": text_content
                })
    return posts

def generate_site():
    env = Environment(loader=FileSystemLoader("templates"))
    index_template = env.get_template("index.html")
    
    posts = load_posts()
    output_dir = "output"
    os.makedirs(output_dir, exist_ok=True)
    
    index_html = index_template.render(posts=posts)
    with open(os.path.join(output_dir, "index.html"), "w", encoding="utf-8") as f:
        f.write(index_html)
    
    css_content = """
    body {
        font-family: Arial, sans-serif;
        background-color: #f5f5f5;
        color: #333;
        margin: 0;
        padding: 20px;
        display: flex;
        justify-content: center;
    }
    .container {
        max-width: 600px;
        width: 100%;
        padding: 20px;
        background: white;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }
    .content {
        display: flex;
        flex-direction: column;
        gap: 20px;
    }
    .post {
        display: flex;
        flex-direction: column;
        align-items: center;
        border-bottom: 1px solid #ddd;
        padding-bottom: 20px;
        margin-bottom: 20px;
    }
    .post img {
        width: 100%;
        border-radius: 10px;
    }
    h1 {
        font-size: 2em;
        margin-bottom: 20px;
        text-align: center;
    }
    a {
        color: #0066cc;
        text-decoration: none;
    }
    a:hover {
        text-decoration: underline;
    }
    """
    with open(os.path.join(output_dir, "style.css"), "w", encoding="utf-8") as f:
        f.write(css_content)
    
    print("Static site generated in the 'output' directory.")

if __name__ == "__main__":
    generate_site()