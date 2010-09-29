# PooledCurbDataSource
#
# obtains http clients (Curl::Easy objects) through a pool. 
#
# esto es importante porque si reutilizamos los clientes HTTP (curb) tenemos alguna
#
# usage:
#   http_client_pool = CommonPool::ObjectPool.new(PooledCurbDataSource.new)
#   curb_client = http_client_pool.borrow_object
#   ..
#   http_client_pool.return_object(curb_client)
#
# see:
#    http://github.com/jugend/common-pool

class PooledCurbDataSource < CommonPool::PoolDataSource
  def create_object
    Curl::Easy.new
  end
end