const Sequelize = require('sequelize')
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

//Criação de tabela NodeJs
const Postagem = sequelize.define('postagens',{
    titulo: {
        type: Sequelize.STRING
    },
    conteudo: {
        type: Sequelize.TEXT
    }
})
//Postagem.sync({force: true})
    //Inserir dados na tabela
    Postagem.create({
        titulo: "titulo teste inclusao",
        console: "Inicando o NodeJs"
    })
    //-----------------------
//----------------------
const Usuario = sequelize.define('usuarios',{
    nome: {
        type: Sequelize.STRING
    },
    idade: {
        type: Sequelize.STRING
    },
    email: {
        type: Sequelize.INTEGER
    }
})
//Usuario.sync({force: true})