Piotr Opyrchał

# Sprawozdanie 8: Git action deployment pipeline
## Cel zajęć:
Zapoznanie się z działaniem GitHub Actions oraz sposobem automatyzacji procesu testowania i wdrażania aplikacji. Celem ćwiczenia było utworzenie pipeline’u CI/CD, który wykorzystuje sekrety do bezpiecznego logowania się do Docker Huba oraz automatycznie publikuje zbudowany obraz kontenera.

## 1. Przygotowanie 

Stworzenie tokenu dostępu na Docker Hub. Zakładka Account Settings/Personal Access tokens:

![Screen1](../screenshots/2.3.png)

Stworzenie sekretów do zabezpieczenia loginu i hasła. Na GitHubie należy wejść w swoje prywatne repozytorium, wybrał jego ustawienia po czym wybrać zakładkę Secrets and variable/Actions:

![Screen2](../screenshots/2.4.png)

Skopiowanie i ułożenie przygotowanych plików w odpowiednim ustawieniu:

![Screen3](../screenshots/3.png)

## 2. Przygotowanie job'ów

W pliku pipeline.yml należało przygotować trzy joby odpowiedzialne za:
- unit-testy - testy jednostkowe

```bash
unit-testy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Set up Python and test libraries
      uses: actions/setup-python@v2
      with:
        python-version: '3.11'

    - name: Install libs for testing
      run: |
        pip install pytest

    - name: prepare environment
      run: |
        cd ./test_lab_8 && python -m pip install -r requirements.txt

    - name: Run tests
      run: |
        cd ./test_lab_8/main && pytest calculator_test.py
```

- funkcjonalne-testy - testy funkcjonalne (jak wskazuje sama nazwa)

```bash
funkcjonalne-testy:
    runs-on: ubuntu-latest
    needs: unit-testy

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    # logowanie do Docker Hub
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME_406787 }}
        password: ${{ secrets.DOCKER_HUB_406787 }}
    
    - name: Set up QEMU
      uses: docker/setup-qemu-action@v3  # potrzebne dla Buildx

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3 


    - name: Build Docker image for test
      uses: docker/build-push-action@v6  # build+load bez push
      with:
        context: ./test_lab_8
        file: ./test_lab_8/dockerfile
        load: true
        tags: ${{ env.TEST_TAG }}
        push: false

    - name: prepare environment
      run: |
        python -m pip install pytest requests

    - name: Run Docker
      run: |
        docker run -d -p 5000:5000 ${{ env.TEST_TAG }}

    - name: Run test
      run: |
        cd ./test_lab_8/main && pytest app_test.py
```

- deployment - zbudowanie samego obrazu po przejściu poprzednich testów

```bash
deployment:
    runs-on: ubuntu-latest
    needs: funkcjonalne-testy

    steps:
    - name: Checkout code
      uses: actions/checkout@v4


    - name: Login to Docker Hub 
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME_406787 }}
        password: ${{ secrets.DOCKER_HUB_406787 }}

    - name: Set up QEMU 
      uses: docker/setup-qemu-action@v3

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    # budowanie i wypchnięcie obrazu
    - name: Build and Push Docker image
      uses: docker/build-push-action@v6
      with:
        context: ./test_lab_8
        file: ./test_lab_8/dockerfile
        push: true
        tags: ${{ env.LATEST_TAG }}
```

Po commicie, upewnienie się czy wszystkie testy i wdrożenie obrazu przebiegły poprawnie:

![Screen4](../screenshots/4last.png)

## 3. Test obrazu

Pobranie obrazu z dockera:

```bash
docker pull piotropyrchal/env406787:latest
```

Uruchomienie tego kontenera z pobranego obrazy:

```bash
docker run -d -p 5000:5000 piotropyrchal/env406787:latest
```

Uruchomienie testów lokalnie:

```bash
pytest app_test.py
```

Testy przebiegły poprawnie:

![Screen5](../screenshots/testy.png)

