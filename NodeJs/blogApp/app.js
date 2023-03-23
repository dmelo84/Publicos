//Importando módulos
const express    = require('express')
const handlebars = require('express-handlebars')
const bodyParser = require('body-parser')
const mongoose   = require('mongoose')
const app        = express()
const path       = require('path')

//Chama Rotas
const admin      = require('./routes/admin')
const usuarios   = require('./routes/usuario')

//Chama sessão
const session = require('express-session')
const flash = require('connect-flash')

//Carrega Tabelas do Banco
require('./models/Postagem')
const Postagem = mongoose.model('postagens')
require('./models/Categoria')
const Categoria = mongoose.model('categorias')

//Carrega módulo de autenticação
const passport = require('passport')
require('./config/auth')(passport) //carrega arquivo na pagina principal

//Configurações
    //Sessão
    app.use(session({
        secret: 'sessaonode',
        resave: true,
        saveUninitialized: true
    }))

    //Posição fixa do passport
    app.use(passport.initialize())
    app.use(passport.session())
    
    //
    app.use(flash())

    //Middleware
    app.use((req, res, next) =>{
        res.locals.success_msg = req.flash("success_msg")
        res.locals.error_msg   = req.flash("error_msg")
        res.locals.error = req.flash('error')
        res.locals.user = req.user || null;
        next()
    })

    //Body Parser
    app.use(bodyParser.urlencoded({extended: true}))
    app.use(bodyParser.json())

    //Handlebars
    app.engine('handlebars', handlebars({defaultLayout: 'main'}))
    app.set('view engine', 'handlebars');

    //Mongoose
        global.db =  mongoose.connect("mongodb://localhost:27017/blogapp").then(()=>{
            console.log("Conexão Ok")
        }).catch(()=>{
            console.log("Erro na conexão")
        })
    
    //Public
    app.use(express.static(path.join(__dirname,'public')))

//Rotas
    //Home
    app.get('/',(req, res) =>{
        Postagem.find().populate('categoria').sort({data: 'desc'}).then((postagens) => {
            res.render('./index', {postagens: postagens})
        }).catch((err) =>{
            req.flash('error_msg', 'Erro interno.')
            res.redirect('/404')
        })
    })

    app.get('/postagem/:slug', (req, res) => {
        Postagem.findOne({slug: req.params.slug}).then((postagem) =>{
            if(postagem){
                res.render('postagem/index', {postagem: postagem})
            }else{
                req.flash('error_msg', 'Esta postagem nao existe')
                res.redirect('/')
            }
        }).catch((err) => {
            req.flash('error_msg', 'Houve um erro interno')
            res.redirect('/')
        })
    })

    app.get('/categorias/:slug', (req, res) =>{
        Categoria.findOne({slug: req.params.slug}).then((categoria) =>{
            if(categoria){
                Postagem.find({categoria: categoria._id}).then((postagens) =>{
                    res.render('categorias/postagens', {postagens: postagens, categoria: categoria})
                }).catch((err) =>{
                    req.flash('error_msg', 'Erro ao listar os posts!')
                    res.redirect('/')
                })
            }else{
                res.flash(('error_msg', 'Categoria nao encontrada!'))
                res.redirect('/')
            }
        }).catch((err) =>{
            req.flash('error_msg', 'Erro interno ao carregar a categoria.')
            res.redirect('/')
        })
    })

    app.get('/404',(req,res) =>{
        res.send('Erro 404!')
    })

    app.get('/categorias', (req, res) =>{
        Categoria.find().then((categorias) =>{
            res.render('categorias/index',{categorias: categorias})
        }).catch((err) => {
            req.flash('error_msg', "Erro ao listar categorias")
            res.redirect('/')
        })
    })
    //Busca rota do arquivo
    app.use('/admin', admin)
    app.use('/usuarios', usuarios)

//Outros
var Port = 4000
app.listen(Port, () =>{
    console.log("Servidor rodando em - http://localhost:4000")
    console.log("Para fechar Ctrl+C. ")
})