class source {
	class {'source::ndbdserver':} ->
	class {'source::mgmserver':} ->
	class {'source::ndbd':} ->
	class {'source::mgm':} ->
	class {'source::minit':} 
}
