require 'test_helper'

class AlbumsControllerTest < ActionController::TestCase
  setup do
    @album = albums(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:albums)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create album" do
    assert_difference('Album.count') do
      post :create, album: { altname: @album.altname, catalognumber: @album.catalognumber, classification: @album.classification, info: @album.info, name: @album.name, popularity: @album.popularity, privateinfo: @album.privateinfo, reference: @album.reference, releasedate: @album.releasedate, status: @album.status }
    end

    assert_redirected_to album_path(assigns(:album))
  end

  test "should show album" do
    get :show, id: @album
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @album
    assert_response :success
  end

  test "should update album" do
    put :update, id: @album, album: { altname: @album.altname, catalognumber: @album.catalognumber, classification: @album.classification, info: @album.info, name: @album.name, popularity: @album.popularity, privateinfo: @album.privateinfo, reference: @album.reference, releasedate: @album.releasedate, status: @album.status }
    assert_redirected_to album_path(assigns(:album))
  end

  test "should destroy album" do
    assert_difference('Album.count', -1) do
      delete :destroy, id: @album
    end

    assert_redirected_to albums_path
  end
end
