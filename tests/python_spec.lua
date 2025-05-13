local python = require('nvim-language-doc.languages.python')

describe("Running from import statement",  function ()
    it("works on import package", function()
        assert python.extract_module('')        
    end) 
    it("works on from package import module", function ()
        
    end)
    it("works on from package.module import class", function ()
        
    end)


    
end)
