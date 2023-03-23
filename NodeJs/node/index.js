const express = require("express");
const app = express();
const handlebars = require('express-handlebars');
const bodyParser = require('body-parser');
const Post = require('./models/Post')

//Config
  //Templade Engine
    app.engine('handlebars', handlebars({defaultLayout: 'main'}))
    app.set('view engine', 'handlebars')
  
  //Body- Parser
    app.use(bodyParser.urlencoded({extended: false}))
    app.use(bodyParser.json())

  //Inicio do programa
  //Rota 0
  app.get('/', function(reg, res){
    Post.findAll({order: [['id', 'desc']]}).then(function(posts){
      res.render('home', {posts: posts }) 
    })
  })

  //Rota 1
  app.get('/inicio', function(req, res){
      res.render('formulario')
  })

  //Rota 2
  app.post('/cadastro', function(req, res){
    Post.create({
      titulo: req.body.titulo,
      conteudo: req.body.conteudo
    }).then(function(){
      res.redirect('/')
    }).catch(function(erro){
      res.send("Ops, deu ruim "+erro)
    })
  })
  //Rota 3
  app.get('/deletar/:id',function(req, res){
    Post.destroy({where: {'id': req.params.id}}).then(function(){
      res.send("Postagem deletada com sucesso!")
    }).catch(function(erro){
      res.send("Esta postagem não existe")
    })
  })

//Sempre no final do arquivo a chamada do serviço
app.listen(4001, function(){
    console.log("Servidor rodando na url http://localhost:4001")
    console.log('Para desligar o server: ctrl + c')
})
//-----------------------------------------------