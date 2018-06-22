module MetadataStubbing
  def manifest_root
    Rails.root.join('spec', 'fixtures', 'manifests')
  end

  def tei_root
    Rails.root.join('spec', 'fixtures', 'tei')
  end

  def stubbed_manifest(file_name)
    File.read(File.join(manifest_root, file_name))
  end

  def stubbed_tei(file_name)
    File.read(File.join(tei_root, file_name))
  end

  def stubbed_annotation(file_name)
    File.read(Rails.root.join('spec', 'fixtures', 'annotations', file_name))
  end
end
