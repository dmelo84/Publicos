const mongoose = require('mongoose');

global.db = mongoose.connect('mongodb://localhost:27017/dbmongo');
mongoose.connection.on('connected', function () {
 console.log('=====Conexao estabelecida com sucesso=====');
});
mongoose.connection.on('error', function (err) {
 console.log('=====Ocorreu um erro: ' + err);
});
mongoose.connection.on('disconnected', function () {
 console.log('=====Conexao finalizada=====');
}); 

//Model - Usuários
//Definindo o Model
const usuarioSchema = mongoose.Schema({
    nome: {
        type: String,
        require: false
    },
    sobrenome: {
        type: String,
        require: false
    },
    email: {
        type: String,
        require: false
    },
    idade: {
        type: Number,
        require: false
    },
    pais: {
        type: String,
        require: false
    }
    
})
//Collections
 mongoose.model('usuarios', usuarioSchema)

 const novoUsuario = mongoose.model('usuarios')

//Iserir dados no Mongo
new novoUsuario({
    nome: "Sonia",
    sobrenome: "MelCodattoo",
    email: "s.codatto@gmail.com",
    idade: 36,
    pais: "Brasil"
}).save().then(() => {
    console.log("Usuario gravado com sucesso!")
}).catch((err) => {
    console.log("Erro na gravacao. "+err)
})

