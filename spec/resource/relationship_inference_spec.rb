require 'spec_helper'

describe JSONAPI::Serializable::Resource, '.relationship' do
  let(:posts) { [Post.new(id: 1), Post.new(id: 2)] }
  let(:user) { User.new(id: 'foo', posts: posts) }

  class SerializableBlog < JSONAPI::Serializable::Resource
    type 'blogs'
  end

  it 'allows specifying serializable class explicitly' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts, class: SerializableBlog
    end
    resource = klass.new(object: user)
    actual = resource.jsonapi_related([:posts])[:posts]

    expect(actual.first.class).to eq(SerializableBlog)
  end

  it 'allows specifying serializable class explicitly as a string' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts, class: 'SerializableBlog'
    end
    resource = klass.new(object: user)
    actual = resource.jsonapi_related([:posts])[:posts]

    expect(actual.first.class).to eq(SerializableBlog)
  end

  it 'allows specifying serializable classes explicitly as a hash' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts, class: { Post: 'SerializableBlog' }
    end
    resource = klass.new(object: user)
    actual = resource.jsonapi_related([:posts])[:posts]

    expect(actual.first.class).to eq(SerializableBlog)
  end

  it 'uses custom inferrer if available' do
    klass = Class.new(JSONAPI::Serializable::Resource) do
      type 'users'
      relationship :posts
    end
    inferrer = proc { |_resource_class_name| SerializableBlog }
    resource_builder = JSONAPI::Serializable::ResourceBuilder.new(inferrer)
    resource = klass.new(object: user, _resource_builder: resource_builder)
    actual = resource.jsonapi_related([:posts])[:posts]

    expect(actual.first.class).to eq(SerializableBlog)
  end
end
