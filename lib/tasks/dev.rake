namespace :dev do

  DEFAULT_PASSWORD = 123456
  DEFAULT_FILES_PATH = File.join(Rails.root, 'lib', 'tmp')

  desc "Configura o ambiente de desenvolvimento"
  task setup: :environment do
    if Rails.env.development?
      show_spinner("Apagando DB...") { %x(rails db:drop) }
      show_spinner("Criando DB...") { %x(rails db:create) }
      show_spinner("Migrando DB...") { %x(rails db:migrate) }
      show_spinner("Cadastrando o administrador padrão...") { %x(rails dev:add_default_admin) }
      show_spinner("Cadastrando administradores extras...") { %x(rails dev:add_extra_admins) }
      show_spinner("Cadastrando o usuario padrão...") { %x(rails dev:add_default_user) }
      show_spinner("Cadastrando os assuntos padrões...") { %x(rails dev:add_subjects) }
      show_spinner("Cadastrando questoes e respostas...") { %x(rails dev:add_answers_and_questions) }
    else
      puts "Não é ambiente de desenvolvimento"
    end
  end
  
  desc "Adiciona o administrador padrão"
  task add_default_admin: :environment do
    Admin.create!(
      email: "admin@teste.com",
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc "Adiciona administrator extras"
  task add_extra_admins: :environment do
    10.times do |i|
      Admin.create!(
        email: Faker::Internet.email,
        password: DEFAULT_PASSWORD,
        password_confirmation: DEFAULT_PASSWORD
      )
    end
  end

  desc "Adiciona o usuario padrão"
  task add_default_user: :environment do
    User.create!(
      email: "user@teste.com",
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc "Adiciona assuntos padrões"
  task add_subjects: :environment do
    file_name = 'subjects.txt'
    file_path = File.join(DEFAULT_FILES_PATH, file_name)

    File.open(file_path, 'r').each do |line|
      Subject.create!(description: line.strip)
    end
  end

  desc "Adiciona questoes e respostas"
  task add_answers_and_questions: :environment do
    Subject.all.each do |subject|
      rand(5..10).times do |i|
        params = create_question_params(subject)
        answers_array = params[:question][:answers_attributes]

        add_answers(answers_array)
        elect_true_answer(answers_array)

        Question.create!(params[:question])
      end
    end
  end
      
  private 

  def elect_true_answer(answers_array = [])
    selected_answer = rand(answers_array.size)
    answers_array[selected_answer][:correct] = true
  end

  def add_answers(answers_array = [])
    rand(2..5).times do |j|
      answers_array << create_answer_params # << é o push do array
    end
  end

  def create_question_params(subject = Subject.all.sample)
    {
      question: {
        description: "#{Faker::Lorem.paragraph} #{Faker::Lorem.question}",
        subject: subject,
        answers_attributes: []
      }
    }
  end

  def create_answer_params(correct = false)
    {
      description: Faker::Lorem.sentence,
      correct: correct
    }
  end

  def show_spinner(msg_start, msg_end = "✔")
    spinner = TTY::Spinner.new("[:spinner] #{msg_start}")
    spinner.auto_spin
    yield
    spinner.success("#{msg_end}")
  end
end
