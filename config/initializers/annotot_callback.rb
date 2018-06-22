Annotot::Annotation.after_commit do
  IndexAnnotationJob.perform_later(self)
end
