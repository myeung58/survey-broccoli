get '/' do
  if signed_in?
    @my_surveys = Survey.where(created_by: current_user.username)
    @other_surveys = Survey.all.select { |survey| survey.created_by != current_user.username }
  else
    @other_surveys = Survey.all
  end
  erb :index
end


get '/signin' do
  if !signed_in?
    erb :signin
  end
end

post '/signin' do
  @user = User.find_by(username: params[:username])
  if @user
    session[:user_id] = @user.id
  end
  redirect '/'
end

get '/signup' do
  if !signed_in?
    erb :signup, layout: false
  end
end

post '/signup' do
  # for bcrypt
  # @user = User.new(params[:user])
  # @user.password = params[:password]
  # @user.save!
  @user = User.create(params)
  session[:user_id] = @user.id
  redirect '/'
end

get '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/surveys/:survey_id' do
  redirect "/surveys/#{params[:survey_id]}/result"
end

# fill survey
get '/surveys/:survey_id/take' do
  if current_user
    Taken.where(user_id: current_user.id, survey_id: params[:survey_id]).length != 0
      # erb :survey_take_success_message, layout: false
      "<p class='taken-message'>You have taken this survey before</p>"
  end
    @survey_being_taken = Survey.find(params[:survey_id])
    @questions = @survey_being_taken.questions
    @question_number = 1
    erb :survey_take, layout: false
end

# submit survey
get '/surveys/:survey_id/submit' do
  params.each do |key, value|
    if key.include?("question")
      question_id = key.gsub("question", "").to_i
      SurveyResult.create(choice: value, question_id: question_id, survey_id: params[:survey_id])
    end
  end
  if signed_in?
    Taken.create(user_id: current_user.id, survey_id: params[:survey_id])
  end
  erb :survey_take_success_message, layout: false
end

# see survey result
get '/surveys/:survey_id/result' do
  @survey_being_viewed = Survey.find(params[:survey_id]) 
  @questions = @survey_being_viewed.questions
  @question_number = 1
  erb :survey_result, layout: false
end



