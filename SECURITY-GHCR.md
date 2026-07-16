# Guía de Seguridad — GitHub Container Registry (GHCR)

## ¿Qué estamos haciendo?

Cada vez que hagas `git push` a `main`, GitHub Actions compila automáticamente la
imagen Docker y la sube a GitHub Packages (GHCR):
```
ghcr.io/carlonox/proyecto-final-redes/servidor-gns3:latest
ghcr.io/carlonox/proyecto-final-redes/servidor-gns3:commit-abc123
```

## ¿Qué necesita GitHub Actions?

**Nada.** El workflow usa `secrets.GITHUB_TOKEN`, un token automático que GitHub
inyecta en cada ejecución del Actions. Tiene permisos de `packages: write`
dentro del mismo repositorio — no hay que configurar nada.

## ¿Qué necesita cada computadora para bajar la imagen?

Para que `docker compose up -d` descargue la imagen desde GHCR sin pedir
autenticación, la imagen debe ser **pública**. Por defecto, GHCR crea las
imágenes privadas. Hay que hacerlas públicas manualmente.

### Paso 1: Hacer la imagen pública (una sola vez)

1. Ir a: https://github.com/settings/packages
2. Buscar el paquete `servidor-gns3` (aparece después del primer push del Actions)
3. Click en **Package settings** (a la derecha)
4. En **Visibility**, seleccionar **Public**
5. Confirmar con **Make public**

> ⚠️ Si la imagen queda privada, cualquiera que haga `docker compose up` recibirá
> `denied: requested access to the resource is denied` hasta que se autentique.

### Paso 2 (opcional): Autenticar Docker con GHCR

Si por algún motivo dejas la imagen privada, cada persona debe:

```bash
# 1. Crear un Personal Access Token (PAT) en:
#    https://github.com/settings/tokens/new
#    - Seleccionar: write:packages + read:packages

# 2. Iniciar sesión en Docker:
echo <TU_PAT> | docker login ghcr.io -u carlonox --password-stdin
```

### Paso 3: Permisos del workflow (GitHub Actions)

El workflow ya los tiene en el archivo YAML:
```yaml
permissions:
  contents: read
  packages: write    # <-- Esto permite subir a GHCR
```

No necesitas crear ningún PAT para el Actions. El `GITHUB_TOKEN` se genera
automáticamente en cada ejecución.

---

## Resumen

| Quién | Necesita hacer algo? |
|---|---|
| GitHub Actions (el CI/CD) | ❌ Nada — usa el token automático |
| Vos (para pushear) | ❌ Nada — el Actions se activa solo |
| Tus compañeros (para bajar la imagen) | ⚠️ Solo si la imagen es privada |
| El profe (para evaluar) | ❌ Nada — `bash setup.sh` y ya |

---

## ¿Cómo verificar que funciona?

```bash
# 1. Hacé push a main
git push origin main

# 2. Mirá el workflow correr:
#    https://github.com/carlonox/proyecto-final-redes/actions

# 3. Cuando termine (verde ✅), probá en cualquier PC:
docker compose -f docker/docker-compose.yml pull
```
