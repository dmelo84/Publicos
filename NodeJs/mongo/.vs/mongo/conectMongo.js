const mongoose = require('mongoose')

mongoose.connect('mongodb//localhost/dbmongo').then(() =>{
    console.log("MongoDB conectado com sucesso!")
}).catch((err) =>{
    console.log("Erro na conex�o com o MongoDB")
})