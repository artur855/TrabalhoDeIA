import 'dart:io';

import 'package:app/detect.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:app/usuario.dart';
import 'package:app/cameralogin.dart';
import 'package:flutter/widgets.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  TextEditingController loginController = TextEditingController();
  TextEditingController senhaController = TextEditingController();

  bool erroLogin = false;
  @override
  void dispose() {
    loginController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children  : <Widget>[
            Container(
              width: 250,
              child: TextField(
                controller: loginController,
                decoration: InputDecoration(
                  labelText: 'Usuario:',
                  errorText: erroLogin ? 'Usuario ou Senha incorretos' : null,
                ),
              ),
            ),
            Container(
              width: 250,
              child: TextField(
                controller: senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha:',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                child: Text('Login'),
                onPressed: () async {
                  String login = loginController.text;
                  String senha = senhaController.text;
                  Usuario usuario = LISTA_USUARIOS.firstWhere(
                      (user) => user.login == login && user.senha == senha,
                      orElse: () => null);
                  if (usuario == null) {
                    setState(() {
                      erroLogin = true;
                    });
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return SucessWidget(usuario: usuario);
                    },
                  ));
                  setState(() {
                    erroLogin = false;
                  });
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return LoginWithCameraWidget();
            },
          ));
        },
      ),
    );
  }
}

class LoginWithCameraWidget extends StatefulWidget {
  @override
  _LoginWithCameraWidgetState createState() => _LoginWithCameraWidgetState();
}

class _LoginWithCameraWidgetState extends State<LoginWithCameraWidget> {
  TextEditingController controller = new TextEditingController();
  Rekognition rekognition = Rekognition();
  bool erro = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logar com camera'),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 250,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Usuario:',
                    errorText: erro ? 'Usuario incorreto' : null,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  child: Text('Continuar'),
                  onPressed: () async {
                    String login = controller.text;
                    Usuario usuario = LISTA_USUARIOS.firstWhere(
                        (usr) => usr.login == login,
                        orElse: () => null);
                    if (usuario == null) {
                      setState(() {
                        erro = true;
                      });
                      return;
                    }
                    var cameras = await availableCameras();
                    var frontal = cameras.firstWhere(
                        (cam) => cam.lensDirection == CameraLensDirection.front,
                        orElse: () => null);
                    var path =
                        await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return TakePictureScreen(
                            camera: frontal ?? cameras.first);
                      },
                    ));

                    if (path == null || path.isEmpty) {
                      setState(() {
                        erro = true;
                      });
                    }
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return Container(
                          width: double.infinity,
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Image.file(
                                  File(path),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ));
                    File nova = File(path);
                    bool sucesso = await rekognition.test(nova, usuario.login);
                    print(sucesso ? 'FOI UM SUCESSO' : 'NAO E VC CARA');
                    Navigator.pop(context);
                    Navigator.pop(context);
                    if (sucesso) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SucessWidget(
                                usuario: usuario,
                              )));
                      setState(() {
                        erro = false;
                      });
                    } else {
                      setState(() {
                        erro = true;
                      });
                    }
                  },
                ),
              )
            ]),
      ),
    );
  }
}

class SucessWidget extends StatelessWidget {
  Usuario usuario;

  SucessWidget({this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text('Seja bem vindo ${usuario.login}!'),
        ),
      ),
    );
  }
}
