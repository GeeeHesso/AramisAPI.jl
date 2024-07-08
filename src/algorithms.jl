
function check_python_version()
    sys = pyimport("sys")
    return sys.version_info[1:2] == (3, 7)
end
