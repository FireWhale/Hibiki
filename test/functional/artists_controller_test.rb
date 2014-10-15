require 'test_helper'

class ArtistsControllerTest < ActionController::TestCase
  setup do
    @artist = artists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:artists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create artist" do
    assert_difference('Artist.count') do
      post :create, artist: { activity: @artist.activity, altname: @artist.altname, birthdate: @artist.birthdate, category: @artist.category, dbcomplete: @artist.dbcomplete, debutdate: @artist.debutdate, info: @artist.info, name: @artist.name, popularity: @artist.popularity, privateinfo: @artist.privateinfo, reference: @artist.reference, status: @artist.status, synopsis: @artist.synopsis }
    end

    assert_redirected_to artist_path(assigns(:artist))
  end

  test "should show artist" do
    get :show, id: @artist
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @artist
    assert_response :success
  end

  test "should update artist" do
    put :update, id: @artist, artist: { activity: @artist.activity, altname: @artist.altname, birthdate: @artist.birthdate, category: @artist.category, dbcomplete: @artist.dbcomplete, debutdate: @artist.debutdate, info: @artist.info, name: @artist.name, popularity: @artist.popularity, privateinfo: @artist.privateinfo, reference: @artist.reference, status: @artist.status, synopsis: @artist.synopsis }
    assert_redirected_to artist_path(assigns(:artist))
  end

  test "should destroy artist" do
    assert_difference('Artist.count', -1) do
      delete :destroy, id: @artist
    end

    assert_redirected_to artists_path
  end
end
