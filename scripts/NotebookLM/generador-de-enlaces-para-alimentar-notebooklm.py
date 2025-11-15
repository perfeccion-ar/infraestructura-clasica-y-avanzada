import os
import re


def extract_links_from_directory(directory):
    url_pattern = re.compile(r"https?://[^\s)]+")
    links = set()

    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith((
                ".md",
                ".txt",
                ".html",
                ".rst",
            )):  # Archivos comunes en repos y wikis
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        content = f.read()
                        found_links = url_pattern.findall(content)
                        links.update(found_links)
                except Exception as e:
                    print(f"Error leyendo {file_path}: {e}")
    return links


# Rutas locales del repositorio y la wiki
repo_path = "infraestructura-clasica-y-avanzada"
wiki_path = "infraestructura-clasica-y-avanzada.wiki"

# Extraer enlaces
repo_links = extract_links_from_directory(repo_path)
wiki_links = extract_links_from_directory(wiki_path)

# Combinar y ordenar
all_links = sorted(repo_links.union(wiki_links))

# Mostrar resultados
print("Enlaces encontrados:")
for link in all_links:
    print(link)
