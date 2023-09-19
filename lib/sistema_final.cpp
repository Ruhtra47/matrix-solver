#include <bits/stdc++.h>
using namespace std;

#define MAXN 1001

struct Complex {
    double a, b;

    double mod() {
        return sqrt(a * a + b * b);
    }

    Complex operator + (Complex z) {
        Complex res;
        res.a = a + z.a;
        res.b = b + z.b;
        return res;
    }

    Complex operator - (Complex z) {
        Complex res;
        res.a = a - z.a;
        res.b = b - z.b;
        return res;
    }

    Complex operator * (Complex z) {
        Complex res;
        res.a = (a * z.a) - (b * z.b);
        res.b = (a * z.b) + (b * z.a);
        return res;
    }

    Complex operator / (Complex z) {
        Complex res;
        res.a = ((a * z.a) + (b * z.b)) / ((z.a * z.a) + (z.b * z.b));
        res.b = ((b * z.a) - (a * z.b)) / ((z.a * z.a) + (z.b * z.b)); 
        return res;
    }

    bool operator < (Complex z) {
        return (*this).mod() < z.mod();
    }

    bool operator > (Complex z) {
        return (*this).mod() > z.mod();
    }
};

int n;
Complex solutions[MAXN], mat[MAXN][MAXN];

int scaleMatrix() {

    for (int i = 0; i < n; i++) {
        int row = i;

        for (int j = i + 1; j < n; j++) {
            if (mat[j][i] > mat[row][i]) row = j; // partial pivoting, isso vai diminuir a diferença entre os números para evitar grandes erros de arredondamento
        }

        if ((abs(mat[i][row].a) < 1e-9) && (abs(mat[i][row].b) < 1e-9)) return i; // se isso acontecer quer dizer que a diagonal tem um 0

        if (row != i) swap(mat[i], mat[row]); // isso vai completar o partial pivoting

        for (int j = i + 1; j < n; j++) {
            auto x = (mat[j][i] / mat[i][i]); // calcular qual deve ser o fator que vai multiplicar a linha
            for (int k = i + 1; k <= n; k++) {
                mat[j][k] = mat[j][k] - mat[i][k] * x; // somar ele a cada número da linha
            }
            mat[j][i].a = 0, mat[j][i].b = 0; // zerar logo a matriz triangular
        }
    }

    return -1;  
}

void findSolutions() {
    for (int i = n - 1; i >= 0; i--) {
        solutions[i] = mat[i][n]; //  começamos com o valor que está na matriz

        for (int j = i + 1; j < n; j++) {
            solutions[i] = solutions[i] - mat[i][j] * solutions[j]; // vamos subtraindo as variáveis que estão pra direita vezes os seus coeficientes
        }

        solutions[i] = solutions[i] / mat[i][i]; // dividimos pelo coeficiente da variável atual
    }
}

void solve() {
    int flag = scaleMatrix();

    if (flag != -1) { // significa que não tem solução única
        if ((abs(mat[flag][n].a) < 1e-9) && (abs(mat[flag][n].b) < 1e-9)) { // significa que tem alguma coisa tipo 0x = 0, ou seja, indeterminado
            cout << "Sistema Possível e Indeterminado\n";
        } else {
            cout << "Sistema Impossível\n"; // significa que tem algo do tipo 0x = c, ou seja, impossível
        }

        return;
    }

    findSolutions();

    for (int i = 0; i < n; i++) {
        cout << "X" << i + 1 << " = ";
        if (solutions[i].b >= 0) cout << solutions[i].a << " + j" << solutions[i].b << "\n"; // deixa o output bonitinho :)
        else cout << solutions[i].a << " - j" << abs(solutions[i].b) << "\n";
    }
}

int main() {
    ios::sync_with_stdio(false); ios_base::sync_with_stdio(false); cin.tie(nullptr); cout.tie(nullptr);
    freopen("sistema.in", "r", stdin);
    freopen("sistema.out", "w", stdout);
    cin >> n;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j <= n; j++) {
            cin >> mat[i][j].a >> mat[i][j].b;
        }
    }

    solve();
}