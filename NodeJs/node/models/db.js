const Sequelize = require('sequelize');

  //Conexão com o Banco de dados
  const sequelize = new Sequelize('dbNode', 'root', 'root', {
    host: 'localhost',
    dialect: 'mysql'
})

  //Teste de conexão com o Banco
  sequelize.authenticate().then(function(){
    console.log("Conectado com sucesso!")
}).catch(function(erro){
    console.log("Falha ao se conectar: "+erro)
})

  //Exporta o Objeto - Ainda não a logica disso
module.exports = {
    Sequelize: Sequelize,
    sequelize: sequelize
}