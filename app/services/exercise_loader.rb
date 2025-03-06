# frozen_string_literal: true

class ExerciseLoader
  def run(_language_version)
    docker_exercise_api.download(lang_name)
  end
end
