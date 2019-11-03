import "package:flutter/material.dart";

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  String _imcText = "Informe seus dados!";

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _resetFields() {
    this.weightController.text = "";
    this.heightController.text = "";
    setState(() {
      _imcText = "Informe seus dados!";
      _formKey = GlobalKey<FormState>();
    });
  }

  void _calcImc() {
    setState(() {
      double weight = double.parse(this.weightController.text);
      double height = double.parse(this.heightController.text) / 100;
      double imc = weight / (height * height);

      if (imc < 18.6) {
        _imcText = "Abaixo do peso (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 18.6 && imc <= 24.9) {
        _imcText = "Peso ideal (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 24.9 && imc <= 29.9) {
        _imcText = "Levemente acima do peso (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 29.9 && imc <= 34.9) {
        _imcText = "Obesidade grau I (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 34.9 && imc <= 39.9) {
        _imcText = "Obesidade grau II (${imc.toStringAsPrecision(4)})";
      } else if (imc >= 40) {
        _imcText = "Obesidade grau III (${imc.toStringAsPrecision(4)})";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Calculadora de IMC"),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: this._resetFields)
          ],
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.person_outline, size: 100, color: Colors.green),
                TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Peso (kg)",
                        labelStyle: TextStyle(color: Colors.green)),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, fontSize: 20),
                    controller: this.weightController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Insira seu peso";
                      }
                      return null;
                    }),
                TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Altura (cm)",
                        labelStyle: TextStyle(color: Colors.green)),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, fontSize: 20),
                    controller: this.heightController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Insira sua altura";
                      }
                      return null;
                    }),
                Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Container(
                        height: 50,
                        child: RaisedButton(
                            color: Colors.green,
                            child: Text(
                              "Calcular",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                this._calcImc();
                              }
                            }))),
                Text(this._imcText,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.green, fontSize: 20))
              ],
            ),
          ),
        ));
  }
}
