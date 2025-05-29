from calculator import dodawanie,dzielenie,mnozenie,odejmowanie, srednia, maksimum, minimum
def test_dodawanie():
    assert dodawanie(2, 3) == 5
    assert dodawanie(-1, 1) == 0

def test_odejmowanie():
    assert odejmowanie(5, 3) == 2
    assert odejmowanie(1, -1) == 2

def test_mnozenie():
    assert mnozenie(2, 3) == 6
    assert mnozenie(-1, 1) == -1

def test_dzielenie():
    assert dzielenie(6, 3) == 2
    assert dzielenie(1, -1) == -1
    assert dzielenie(1, 0) == "Błąd: dzielenie przez zero!"

def test_srednia():
    assert srednia([1, 2, 3, 4]) == 2.5
    assert srednia([10, 20]) == 15

def test_maksimum():
    assert maksimum([1, 5, 3]) == 5
    assert maksimum([-10, -5, -1]) == -1

def test_minimum():
    assert minimum([1, 5, 3]) == 1
    assert minimum([-10, -5, -1]) == -10