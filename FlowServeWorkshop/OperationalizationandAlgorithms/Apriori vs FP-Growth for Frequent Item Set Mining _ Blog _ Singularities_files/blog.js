(function() {


}).call(this);



function loadMoreArticles(category_visual, category_slug){
	var list_of_posts = [];
	var list_of_current_post = getListOfCurrentPosts(category_visual);

	$.ajax({
		type:"post", 
		url:"http://singularities.com/blog/category/"+category_slug, 
		data:{}, 
		success:function(data)
		{
			data = JSON.parse(data);
			list_of_posts = data.entries;
			var list_of_post_to_show = getListOfPostToShow(list_of_current_post, list_of_posts);
			renderArticles(list_of_post_to_show, category_visual, list_of_posts, category_slug);
		}, 
		error:function(data)
		{
			console.log('error');
		}
	});
}




function renderArticles(list_of_posts, category_segment, list_of_posts_returned, category_slug){
	for(var i = 0; i < list_of_posts.length; i++){
		var newPost = article_structure = "<li id='"+list_of_posts[i].slug+"_"+list_of_posts[i].id+"_"+list_of_posts[i].created_on+"'>"+
							    "<div class='row'>"+
							      	"<div class='small-12 medium-6 columns'>"+
							        	"<img src='/uploads/default/files/"+list_of_posts[i].description_image.filename+"'>"+
							      	"</div>"+
							      	"<div class='small-12 medium-6 large-5 end columns'>"+
							        	"<a href='"+list_of_posts[i].url+"'>"+
							          		"<h3 class='title list-body-text bold'>"+list_of_posts[i].title+"</h3>"+
							        	"</a>"+
							        	"<p class='list-body-text'>"+list_of_posts[i].intro+"</p>"+
							        	"<a class='list-body-text' href='"+list_of_posts[i].url+"'>"+
							          		"View article"+
							        	"</a>"+
							      	"</div>"+
							    "</div>"+
							"</li>";
		$("#"+category_segment+"").append(newPost);
	}
	var list_of_current_post = getListOfCurrentPosts(category_segment);
	if(list_of_posts_returned.length == list_of_current_post.length){
		$("#more-"+category_slug).hide();
	}
	return false;
}

function getListOfCurrentPosts(category_visual){
	var list_of_current_post = $("#"+category_visual+"").children();
	var result = [];
	var object = {id:"", created_on:"", slug:""};
	for(var i = 0; i < list_of_current_post.length; i++){
		var new_object = jQuery.extend(true, {}, object);
		var element = $(list_of_current_post[i]).attr('id');
		element = element.split('_');
		new_object.id = element[1];
		new_object.created_on = element[2];
		new_object.slug = element[0];
		result.push(new_object);
	}

	return result;
}


function isShowed(element, list_of_elements){
	var result = false;
	for(var i =0; i<list_of_elements.length; i++){
		if(element.id == list_of_elements[i].id && element.created_on == list_of_elements[i].created_on && element.slug == list_of_elements[i].slug){
			result = true;
		}
	}
	return result;
}

function getListOfPostToShow(list_of_current_post, list_of_posts){
	var result = [];
	for(var i = 0; i < list_of_posts.length; i++){
		if(!isShowed(list_of_posts[i], list_of_current_post)){
			result.push(list_of_posts[i]);
		}
	}
	return result;
}



