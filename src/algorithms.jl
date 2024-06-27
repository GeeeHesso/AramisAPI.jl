
function get_python_version()
    sys = pyimport("sys")
    return sys.version_info
end
