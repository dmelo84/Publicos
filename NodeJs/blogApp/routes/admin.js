const express = require('express')
const router = express.Router()

//Referencia Externa do Model
const mongoose = require('mongoose')
require('../models/Categoria')
const Categoria = mongoose.model('categorias') //Objeto Tabela
require('../models/Postagem')
const Postagem = mongoose.model('postagens')
const {eAdmin} = require('../helpers/eAdmin') //Proteção de rota
//

router.get('/', eAdmin, (req, res) =>{
    res.render('admin/index')
})

router.get('/categorias', eAdmin, (req, res) =>{
    Categoria.find().sort({date: 'desc'}).then((categorias) =>{
        res.render('admin/categorias', {categorias: categorias})
    }).catch(()=>{
        req.flash('error_msg', 'Houve um erro ao listar as categorias')
        res.redirect('/admin')
    })
    
})

router.get('/categorias/add', eAdmin, (req, res) => {
    res.render('admin/addcategorias')
})

router.post('/categorias/nova', eAdmin, (req, res) =>{

    var erros = [];
    if(!req.body.nome || typeof req.body.nome == undefined || req.body.nome == null ){
        erros.push({texto: 'Nome Invalido.'})
    }

    if(!req.body.slug || typeof req.body.slug == undefined || req.body.slug == null){
        erros.push({texto: 'Slug invalido.'})
    }

    if(req.body.nome.length < 2 ){
        erros.push({texto: 'Nome da categoria muito pequeno.'})
    }

    if(erros.length > 0 ){
        res.render('admin/addcategorias', {erros: erros})
    }else{
        var novaCategoria = {
            nome: req.body.nome,
            slug: req.body.slug
        }

        new Categoria(novaCategoria).save().then(()=>{
            req.flash('success_msg', 'Categoria criada com sucesso.')
            res.redirect('/admin/categorias')
        }).catch((err)=>{
            req.flash("error_msg", 'Houve um erro ao criar a categoria, tente novamente!')
            res.redirect("/admin")
        })
    }
} )

router.get('/categorias/edit/:id', eAdmin, (req, res) => {
    Categoria.findOne({_id:req.params.id}).then((categoria) =>{
        res.render('admin/editcategorias', {categoria: categoria})
    }).catch((err) =>{
        req.flash('error_msg', 'Categoria inexistente.')
        res.redirect('/admin/categorias')
    })
})

router.post('/categorias/edit', eAdmin, (req, res) => {

    Categoria.findOne({_id: req.body.id}).then((categoria) => {

        categoria.nome = req.body.nome
        categoria.slug = req.body.slug

        categoria.save().then(() => {
            req.flash('success_msg', 'Categoria alterada com sucesso.')
            res.redirect('/admin/categorias')
        }).catch((err) => {
            req.flash('error_msg', 'Erro ao salvar a categoria.')
            res.redirect('/admin/categorias')
        })

    }).catch((err) => {
        req.flash('error_msg', 'Erro ao editar a categoria.')
        res.redirect('/admin/categorias')
    })
})

router.post('/categorias/deletar' , eAdmin, (req, res) => {
    Categoria.remove({_id: req.body.id}).then(() =>{
        req.flash('success_msg', 'Categoria deletada.')
        res.redirect('/admin/categorias')
    }).catch((err) =>{
        req.flash('error_msg', 'Erro ao detetar a categoria')
        res.redirect('/admin/categorias')
    })
})

router.get('/postagens', eAdmin, (req, res) =>{
    Postagem.find().populate('categoria').sort({data:'desc'}).then((postagens) =>{
        res.render('admin/postagens', {postagens: postagens})
    }).catch((error) =>{
        req.flash('error_msg', "Erro ao listar postagens.")
        res.redirect('/admin')
    })
    
})

router.get('/postagens/add', eAdmin, (req, res) =>{
    Categoria.find().then((categorias) =>{
        res.render('admin/addpostagem',{categorias: categorias})
    }).catch((err) => {
        req.flash('error_msg', 'Erro ao listar categorias.')
        res.redirect('/admin')
    })
    
})

router.post('/postagem/nova', eAdmin, (req,res) => {
    var erros = []

    if(req.body.categoria == '0'){
        erros.push({texto: 'Categoria inválida, registre uma categoria.'})
    }
    if(erros.length > 0 ){
        res.render('admin/addpostagem', {erros: erros})
    }else{
       const novaPostagem = {
           titulo: req.body.titulo,
           descricao: req.body.descricao,
           conteudo: req.body.conteudo,
           categoria: req.body.categoria,
           slug: req.body.slug
       } 
       new Postagem(novaPostagem).save().then(() => {
           req.flash('success_msg', 'Postagem criada com sucesso!')
           res.redirect('/admin/postagens')
       }).catch((erro) => {
           req.flash('error_msg', 'Houve um erro na gravação do post.')
           res.redirect('/admin/postagens')
       })
    }
})
   
router.get('/postagens/edit/:id', eAdmin, (req, res) =>{

    Postagem.findOne({_id: req.params.id}).then((postagem) =>{
        Categoria.find().then((categorias) => {
            res.render('admin/editpostagens',{categorias: categorias, postagem: postagem})
        }).catch((err) => {
            req.flash('error_msg', 'Erro ao listar categorias')
            res.redirect('/admin/postagens')
        })
    }).catch((err) => {
        req.flash('error_msg', 'Erro ao listar formulário para edição')
        res.redirect('/admin/postagens')
    })
})

router.post('/postagem/edit', eAdmin, (req, res) =>{
    Postagem.findOne({_id: req.body.id}).then((postagem) => {
        postagem.titulo = req.body.titulo
        postagem.slug = req.body.slug
        postagem.descricao = req.body.descricao
        postagem.conteudo = req.body.conteudo
        postagem.categoria = req.body.categoria

        postagem.save().then(() =>{
            req.flash('success_msg', 'Edicao concluida com sucesso!')
            res.redirect('/admin/postagens')
        }).catch((err) => {
            req.flash('error_msg', 'erro interno')
            res.redirect('/admin/postagens')
        })

    }).catch((err) => {
        console.log(err) //Trata erro no console IMPORTANTE.
        req.flash('error_msg', 'Erro ao salvar a edição do post')
        res.redirect('/admin/postagens')
    })
})

router.get('/postagens/deletar/:id',  eAdmin, (req,res) =>{
    Postagem.remove({_id: req.params.id}).then(() =>{
        req.flash('success_msg', 'Post deletado com sucesso!')
        res.redirect('/admin/postagens')
    }).catch((err) => {
        req.flash('error_msg', 'Erro ao deletar post!')
        console.log(err)
        res.redirect('/admin/postagens')
    })
})

module.exports = router