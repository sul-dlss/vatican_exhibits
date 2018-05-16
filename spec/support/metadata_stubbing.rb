module MetadataStubbing
  def manifest_root
    Rails.root.join('spec', 'fixtures', 'manifests')
  end

  def stubbed_manifest(file_name)
    File.read(File.join(manifest_root, file_name))
  end
end
