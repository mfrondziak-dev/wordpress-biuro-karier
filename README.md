# Strona Biura Praktyk i Karier — demo (WordPress + Docker)

Projekt demonstracyjny: w pełni zautomatyzowana instalacja WordPressa przy użyciu
Dockera i WP-CLI. Pojedyncza komenda uruchamia kompletną stronę z treścią demo
(oferty pracy, praktyki i staże, szkolenia, kontakt) — bez ręcznej konfiguracji.

Projekt towarzyszy aplikacji na stanowisko **Młodszy specjalista ds. przedsiębiorczości**
(BiP — obsługa strony internetowej uczelni, praktyki, szkolenia).

## Co pokazuje ten projekt

- **Docker Compose** — trzy usługi: WordPress, MySQL 8.4 (z healthcheckiem) i WP-CLI,
- **automatyzacja** — WP-CLI instaluje WordPressa, tworzy lub aktualizuje strony
  na podstawie plików źródłowych, importuje przykładowy PDF i ustawia stronę główną,
- **nazwane wolumeny** — dane bazy i pliki WordPressa przeżywają restart kontenerów,
- **ładne linki** (permalinki) konfigurowane automatycznie,
- **własny motyw potomny** — responsywny wygląd dopasowany do strony biura.

## Wymagania

- Windows: [Docker Desktop](https://www.docker.com/products/docker-desktop/) (z WSL2) albo
  Docker na Linuksie/macOS. Reszty nie trzeba — nawet PHP nie jest wymagany.

## Szybki start

```powershell
git clone https://github.com/mfrondziak-dev/wordpress-biuro-karier.git
cd wordpress-biuro-karier
docker compose up -d
```

Pierwsze uruchomienie trwa ok. 1–2 minuty (pobranie obrazów + automatyczna instalacja).
Postęp instalacji można obserwować poleceniem:

```powershell
docker compose logs -f wp-cli
```

Gdy zobaczysz `OK: treść demo gotowa`, strona działa:

- **Strona główna:** http://localhost:8080
- **Panel administracyjny:** http://localhost:8080/wp-admin
- **Login / hasło:** `admin` / `admin123` *(dane demonstracyjne — patrz „Uwagi produkcyjne")*

## Co jest w środku

| Strona | Zawartość |
|---|---|
| `/oferty-pracy/` | ogłoszenia o pracę z listą wymagań |
| `/praktyki-i-staze/` | instrukcja krok po kroku + **wzór porozumienia (PDF)** |
| `/szkolenia/` | informacje o Targach Edukacji i Pracy 2026 |
| `/firmy/` | publiczna lista firm i ich branż (bez danych kontaktowych) |
| `/zglos-firme/` | informacje i formularz Google dla wystawców |
| `/kontakt/` | kontakt do organizatorów targów |
| `/` | strona główna ustawiona jako statyczna (Settings → Reading) |

Po zmianie plików w `setup/content/` zaktualizuj istniejącą stronę poleceniem
`docker compose run --rm wp-cli`.

## Przydatne komendy

```powershell
docker compose down        # zatrzymanie (dane zostają w wolumenach)
docker compose up -d       # ponowne uruchomienie (bez duplikowania treści)
docker compose down -v     # pełny reset (usuwa bazę i pliki WordPressa)
```

## Struktura projektu

```
docker-compose.yml        # definicja trzech usług
setup/
  init.sh                 # automatyczna instalacja + zasilenie treścią (WP-CLI)
  content/*.html          # treści stron w formacie bloków Gutenberg
  media/*.pdf             # przykładowy wzór porozumienia
  theme/                  # własny motyw potomny WordPressa
```

Katalog `reference/` zawiera robocze materiały źródłowe (m.in. dane kontaktowe firm)
i celowo nie jest publikowany — jest wykluczony w `.gitignore`.

Jeśli port 8080 jest zajęty: zmień `"8080:80"` na np. `"8081:80"` **oraz** `WP_PORT: "8081"`
w usłudze `wp-cli`, potem `docker compose down -v && docker compose up -d`.

## Uwagi produkcyjne

To demo celowo używa prostych danych logowania i hasła bazy w pliku compose.
Wdrożenie na prawdziwy serwer wymagałoby: unikalnych haseł (plik `.env` w `.gitignore`),
HTTPS za reverse proxy, regularnych kopii zapasowych wolumenów oraz aktualizacji obrazów.

## Licencja

Kod projektu udostępniamy na licencji [MIT](LICENSE). Treści demonstracyjne stron
mają charakter przykładowy — przed użyciem komercyjnym zweryfikuj prawa do materiałów
i danych, na których bazują.
