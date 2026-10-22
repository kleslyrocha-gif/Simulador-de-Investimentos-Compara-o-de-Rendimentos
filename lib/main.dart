
import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simulador de Investimentos',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F6F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const TelaInicial(),
    );
  }
}

// Guarda os dados de cada mês da simulação.
class EvolucaoMensal {
  final int mes;
  final double saldo1;
  final double saldo2;

  EvolucaoMensal(this.mes, this.saldo1, this.saldo2);
}

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final formulario = GlobalKey<FormState>();

  final capital1 = TextEditingController();
  final aporte1 = TextEditingController();
  final taxa1 = TextEditingController();

  final capital2 = TextEditingController();
  final aporte2 = TextEditingController();
  final taxa2 = TextEditingController();

  final meses = TextEditingController();

  // Converte números digitados com vírgula ou ponto.
  double converter(String valor) {
    return double.parse(valor.replaceAll(',', '.'));
  }

  // Campo de texto reutilizável com validação.
  Widget campo(String titulo, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: titulo,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        validator: (valor) {
          if (valor == null || valor.trim().isEmpty) {
            return 'Preencha este campo';
          }

          final numero = double.tryParse(
            valor.replaceAll(',', '.'),
          );

          if (numero == null || numero < 0) {
            return 'Digite um valor válido';
          }

          return null;
        },
      ),
    );
  }

  // Cartão com os campos de um investimento.
  Widget cartaoInvestimento(
    String titulo,
    TextEditingController capital,
    TextEditingController aporte,
    TextEditingController taxa,
  ) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 14),
            campo('Capital inicial (R\$)', capital),
            campo('Aplicação mensal (R\$)', aporte),
            campo('Taxa de juros mensal (%)', taxa),
          ],
        ),
      ),
    );
  }

  void comparar() {
    if (!formulario.currentState!.validate()) {
      return;
    }

    final tempo = int.tryParse(meses.text);

    if (tempo == null || tempo <= 0 || tempo > 600) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Informe um período entre 1 e 600 meses.',
          ),
        ),
      );
      return;
    }

    final c1 = converter(capital1.text);
    final a1 = converter(aporte1.text);
    final t1 = converter(taxa1.text);

    final c2 = converter(capital2.text);
    final a2 = converter(aporte2.text);
    final t2 = converter(taxa2.text);

    double saldo1 = c1;
    double saldo2 = c2;

    final List<EvolucaoMensal> evolucao = [];

    // Calcula os juros compostos de cada mês.
    for (int mes = 1; mes <= tempo; mes++) {
      saldo1 = saldo1 * (1 + t1 / 100) + a1;
      saldo2 = saldo2 * (1 + t2 / 100) + a2;

      evolucao.add(
        EvolucaoMensal(mes, saldo1, saldo2),
      );
    }

    // Total investido = capital inicial + aplicações mensais.
    final totalInvestido1 = c1 + a1 * tempo;
    final totalInvestido2 = c2 + a2 * tempo;

    final rendimento1 = saldo1 - totalInvestido1;
    final rendimento2 = saldo2 - totalInvestido2;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaResultados(
          saldo1: saldo1,
          saldo2: saldo2,
          rendimento1: rendimento1,
          rendimento2: rendimento2,
          evolucao: evolucao,
        ),
      ),
    );
  }

  @override
  void dispose() {
    capital1.dispose();
    aporte1.dispose();
    taxa1.dispose();
    capital2.dispose();
    aporte2.dispose();
    taxa2.dispose();
    meses.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Investimentos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Compare seus investimentos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Preencha os dados para comparar os rendimentos.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  cartaoInvestimento(
                    'Investimento 1',
                    capital1,
                    aporte1,
                    taxa1,
                  ),

                  const SizedBox(height: 12),

                  cartaoInvestimento(
                    'Investimento 2',
                    capital2,
                    aporte2,
                    taxa2,
                  ),

                  const SizedBox(height: 12),

                  campo('Período em meses', meses),

                  const SizedBox(height: 4),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: comparar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Comparar investimentos',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Os resultados são estimativas e não incluem impostos ou taxas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Segunda tela: apresenta a comparação dos resultados.
class TelaResultados extends StatelessWidget {
  final double saldo1;
  final double saldo2;
  final double rendimento1;
  final double rendimento2;
  final List<EvolucaoMensal> evolucao;

  const TelaResultados({
    super.key,
    required this.saldo1,
    required this.saldo2,
    required this.rendimento1,
    required this.rendimento2,
    required this.evolucao,
  });

  String dinheiro(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget cartaoResultado(
    String titulo,
    double saldo,
    double rendimento,
  ) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Montante final'),
            Text(
              dinheiro(saldo),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Rendimento total'),
            Text(dinheiro(rendimento)),
          ],
        ),
      ),
    );
  }

  Widget linhaTabela(
    String mes,
    String valor1,
    String valor2, {
    bool cabecalho = false,
  }) {
    final estilo = TextStyle(
      fontWeight: cabecalho ? FontWeight.bold : FontWeight.normal,
      fontSize: 13,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),
      color: cabecalho
          ? const Color(0xFFE2EDE2)
          : Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(mes, style: estilo),
          ),
          Expanded(
            flex: 2,
            child: Text(
              valor1,
              textAlign: TextAlign.end,
              style: estilo,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              valor2,
              textAlign: TextAlign.end,
              style: estilo,
            ),
          ),
        ],
      ),
    );
  }

  Widget barraComparativa(
    String titulo,
    double saldo,
    double maiorSaldo,
  ) {
    final proporcao =
        maiorSaldo > 0 ? saldo / maiorSaldo : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$titulo: ${dinheiro(saldo)}'),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: proporcao.clamp(0.0, 1.0).toDouble(),
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maiorSaldo = saldo1 > saldo2 ? saldo1 : saldo2;

    String vencedor;

    if (saldo1 > saldo2) {
      vencedor = 'O Investimento 1 teve o maior montante final.';
    } else if (saldo2 > saldo1) {
      vencedor = 'O Investimento 2 teve o maior montante final.';
    } else {
      vencedor = 'Os dois investimentos tiveram o mesmo montante final.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da comparação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Resumo dos resultados',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                cartaoResultado(
                  'Investimento 1',
                  saldo1,
                  rendimento1,
                ),

                cartaoResultado(
                  'Investimento 2',
                  saldo2,
                  rendimento2,
                ),

                Card(
                  color: const Color(0xFFE2EDE2),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      vencedor,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Comparação dos montantes',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                barraComparativa(
                  'Investimento 1',
                  saldo1,
                  maiorSaldo,
                ),
                barraComparativa(
                  'Investimento 2',
                  saldo2,
                  maiorSaldo,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Evolução mensal',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Veja como o saldo dos dois investimentos evolui a cada mês.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 10),

                // Lista comparativa dos saldos de cada mês.
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      linhaTabela(
                        'Mês',
                        'Invest. 1',
                        'Invest. 2',
                        cabecalho: true,
                      ),
                      const Divider(height: 1),
                      ...evolucao.map(
                        (item) => Column(
                          children: [
                            linhaTabela(
                              item.mes.toString(),
                              dinheiro(item.saldo1),
                              dinheiro(item.saldo2),
                            ),
                            const Divider(height: 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                  child: const Text('Nova simulação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
