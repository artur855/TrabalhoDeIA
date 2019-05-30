class Usuario {
  final String login;
  final String senha;
  Usuario(this.login, this.senha);
}

List<Usuario> carregarUsuarios() {
  return [
    Usuario('arthur', '123'),
    Usuario('thiago', '123'),
    Usuario('edmario', '123'),
    Usuario('geraldo', '123'),
    Usuario('matheus', '123'),
  ];
}

List<Usuario> LISTA_USUARIOS = carregarUsuarios();
