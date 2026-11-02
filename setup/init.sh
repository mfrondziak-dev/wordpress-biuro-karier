#!/bin/sh
# Automatyczna instalacja WordPressa i zasilenie treścią demo.
# Skrypt jest idempotentny: przy ponownym uruchomieniu nic nie dubluje się.
set -e

wp() { command wp --path=/var/www/html --allow-root "$@"; }

echo "==> Czekam na pliki WordPressa..."
i=0
while [ ! -f /var/www/html/wp-settings.php ]; do
  i=$((i + 1))
  if [ "$i" -gt 90 ]; then echo "ERROR: timeout na pliki WP"; exit 1; fi
  sleep 2
done

echo "==> Instalacja WordPressa (czekam na bazę danych)..."
i=0
until wp core is-installed >/dev/null 2>&1; do
  wp core install \
    --url="http://localhost:${WP_PORT:-8080}" \
    --title="Biuro Praktyk i Karier — Demo" \
    --admin_user="admin" \
    --admin_password="admin123" \
    --admin_email="admin@example.com" \
    --skip-email >/dev/null 2>&1 || true
  i=$((i + 1))
  if [ "$i" -gt 90 ]; then echo "ERROR: timeout na bazę danych"; exit 1; fi
  sleep 2
done
echo "OK: WordPress zainstalowany."

echo "==> Ustawienia podstawowe..."
wp option update blogname "Biuro Praktyk i Karier" >/dev/null
wp option update blogdescription "Wsparcie w planowaniu kariery, praktykach i rozwoju zawodowym." >/dev/null
wp option update timezone_string "Europe/Warsaw" >/dev/null
wp rewrite structure '/%postname%/' >/dev/null
wp theme activate biuro-karier >/dev/null 2>&1 || true

create_page() {
  slug="$1"; title="$2"; file="$3"
  page_id=$(wp post list --post_type=page --name="$slug" --field=ID 2>/dev/null)
  if [ -n "$page_id" ]; then
    wp post update "$page_id" --post_title="$title" --post_content="$(cat "$file")" >/dev/null
    echo "   = zaktualizowano stronę: $slug"
  else
    wp post create --post_type=page --post_name="$slug" --post_title="$title" \
      --post_status=publish --post_content="$(cat "$file")" >/dev/null
    echo "   + utworzono stronę: $slug"
  fi
}

echo "==> Przykładowy PDF (wzór porozumienia)..."
ATT=$(wp post list --post_type=attachment --field=ID 2>/dev/null | head -n 1)
if [ -z "$ATT" ]; then
  ATT=$(wp media import /setup/media/porozumienie-wzorcowe.pdf --porcelain --title="Wzór porozumienia (demo)")
  echo "   + PDF zaimportowany."
fi
POROZ_URL=$(wp post get "$ATT" --field=guid)
sed "s|__POROZUMIENIE_URL__|${POROZ_URL}|g" /setup/content/praktyki-i-staze.html > /tmp/praktyki.html

echo "==> Tworzę strony demonstracyjne..."
create_page start "Start" /setup/content/start.html
create_page oferty-pracy "Oferty pracy" /setup/content/oferty-pracy.html
create_page praktyki-i-staze "Praktyki i staże" /tmp/praktyki.html
create_page szkolenia "Szkolenia" /setup/content/szkolenia.html
create_page firmy "Baza firm" /setup/content/firmy.html
create_page zglos-firme "Zgłoszenie firmy" /setup/content/zglos-firme.html
create_page kontakt "Kontakt" /setup/content/kontakt.html

echo "==> Strona główna + ładne linki..."
START_ID=$(wp post list --post_type=page --name=start --field=ID)
if [ -n "$START_ID" ]; then
  wp option update show_on_front page >/dev/null
  wp option update page_on_front "$START_ID" >/dev/null
fi
wp rewrite flush >/dev/null

echo "OK: treść demo gotowa."
